package Ocean::Publisher::JSONRPC::ServerFactory;

use strict;
use warnings;

use Ocean::Publisher::JSONRPC::ServerBuilder;
use Ocean::Publisher::JSONRPC::ServerComponentFactory;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    
    }, $class;
    return $self;
}

sub create_server {
    my ($self, $config, $daemonize) = @_;

    my $component_factory =
        $self->_create_server_component_factory();

    my $builder = Ocean::Publisher::JSONRPC::ServerBuilder->new;

    $builder->context(
        $component_factory->create_context($config));

    $builder->event_dispatcher(
        $component_factory->create_event_dispatcher($config));

    $builder->listener(
        $component_factory->create_listener($config));

    $builder->daemonizer(
        $component_factory->create_daemonizer($config, $daemonize));

    $builder->signal_handler(
        $component_factory->create_signal_handler($config));

    return $builder->build();
}

sub _create_server_component_factory {
    my $self = shift;
    return Ocean::Publisher::JSONRPC::ServerComponentFactory->new;
}

1;
