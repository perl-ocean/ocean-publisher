package Ocean::Publisher::JSONRPC::Context;

use strict;
use warnings;

use parent 'Ocean::Context';

use Ocean::Cluster::SerializerFactory;
use Ocean::Cluster::Frontend::RouterEvaluator;

use Ocean::Constants::EventType;
use Ocean::Config;

use Log::Minimal;
use Module::Load;

sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    $self->{_dispatcher} = $args{dispatcher};
    $self->{_serializer} = $args{serializer};
    return $self;
}

sub node_id {
    my $self = shift;
    return $self->config('node_id');
}

sub _create_dispatcher {
    my ($self, $config) = @_;

    my $dispatcher_class = $config->{class}
        or die "dispatcher class is not found";

    Module::Load::load($dispatcher_class);

    unless ($dispatcher_class->isa('Ocean::Cluster::Frontend::Dispatcher')) {
        die sprintf(
            "%s is not sub-class of Ocean::Cluster::Frontend::Dispatcher", 
            $dispatcher_class);
    }

    my $args = $config->{config} || {};
    my $dispatcher = $dispatcher_class->new(%$args);
    return $dispatcher;
}

sub _create_serializer {
    my ($self, $type) = @_;
    $type ||= 'json';
    return Ocean::Cluster::SerializerFactory->new->create($type);
}

sub _create_router {
    my ($self, $router_file) = @_;
    return Ocean::Cluster::Frontend::RouterEvaluator->evaluate($router_file);
}

sub initialize {
    my $self = shift;

    $self->{_serializer} = 
        $self->_create_serializer( $self->config('serializer') )
            unless $self->{_serializer};

    $self->{_dispatcher} = 
        $self->_create_dispatcher( $self->config('dispatcher') )
            unless $self->{_dispatcher};

    $self->{_router} = 
        $self->_create_router( $self->config('router') )
            unless $self->{_router};

    $self->{_router}->setup_dispatcher($self->{_dispatcher});
}

sub post_job {
    my ($self, $type, $args) = @_;

    debugf('<Context> @post { event: %s } ', $type);

    my $data = $self->{_serializer}->serialize({ 
        type    => $type, 
        node_id => $self->node_id,
        args    => $args, 
    });

    my $route = $self->{_router}->match($type, $args);

    warnf("<Handler> route for event '%s' not found", $type)
        unless $route;

    $self->{_dispatcher}->dispatch(
        broker_id  => $route->broker,
        queue_name => $route->queue,
        data       => $data,
    );
}

1;
