package Ocean::Publisher::JSONRPC::Server;

use strict;
use warnings;

use Ocean::Config;
use Ocean::JID;
use Ocean::Constants::EventType;

use AnyEvent;
use Log::Minimal;
use Try::Tiny;

use Ocean::HandlerArgs::PubSubEvent;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _event_dispatcher => $args{event_dispatcher},
        _context          => $args{context},
        _daemonizer       => $args{daemonizer},
        _signal_handler   => $args{signal_handler},
        _listener         => $args{listener},
    }, $class;
    return $self;
}

sub run {
    my $self = shift;
    $self->initialize();
    $self->start();
    $self->wait();
    $self->finalize();
}

sub initialize {
    my $self = shift;

    $self->{_context}->set_delegate($self);
    $self->{_signal_handler}->set_delegate($self);
    $self->{_listener}->set_delegate($self);

    $self->{_context}->initialize();
    $self->{_daemonizer}->initialize();
}

sub start {
    my $self = shift;
    $self->{_exit_guard} = AE::cv;
    $self->{_exit_guard}->begin();
    $self->{_signal_handler}->setup();

    $self->{_listener}->start();
}

sub wait {
    my $self = shift;
    $self->{_exit_guard}->recv();
}

sub finalize {
    my $self = shift;
    $self->{_context}->finalize();
    $self->{_daemonizer}->finalize();
    infof("<Server> exit");
}

sub on_signal_quit {
    my $self = shift;
    $self->shutdown();
}

sub on_listener_prepare {
    my ($self, $host, $port) = @_;
    infof("<Server> started listening on %s:%d", $host, $port);
}

sub on_publish_request {
    my ($self, $res_cv, $params_list) = @_;
 
    my %params = @$params_list; 

    my $args = Ocean::HandlerArgs::PubSubEvent->new({
        from   => $params{from},     
        to     => Ocean::JID->new($params{to}),
        node   => $params{node},
        items  => $params{items},
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::PUBLISH_EVENT,
        $self->{_context}, $args);

    $self->_deliver_response($res_cv, {success => 1});
}

sub _deliver_response {
    my ($self, $res_cv, $response) = @_;
    $res_cv->result($response);
}

sub shutdown {
    my $self = shift;

    infof("<Server> started shutdown...");
    $self->{_listener}->stop();

    infof("<Server> stopped listening");
    $self->{_exit_guard}->end();
}

sub release {
    my $self = shift;
    if ($self->{_listener}) {
        $self->{_listener}->release();
        delete $self->{_listener};
    }
    if ($self->{_context}) {
        $self->{_context}->release();
        delete $self->{_context};
    }
    if ($self->{_signal_handler}) {
        $self->{_signal_handler}->release();
        delete $self->{_signal_handler};
    }
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
