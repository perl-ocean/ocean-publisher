package Ocean::Publisher::JSONRPC::ServerBuilder;

use strict;
use warnings;

use Ocean::Publisher::JSONRPC::Server;
use Ocean::Error;

sub new { 
    my $class = shift;
    my $self = bless {
        _event_dispatcher => undef,
        _daemonizer       => undef,
        _signal_handler   => undef,
        _listener         => undef,
        _context          => undef,
    }, $class;
    return $self;
}

sub context {
    my ($self, $context) = @_;
    $self->{_context} = $context;
    return $self;
}

sub event_dispatcher {
    my ($self, $event_dispatcher) = @_;
    $self->{_event_dispatcher} = $event_dispatcher;
    return $self;
}

sub listener {
    my ($self, $tcp_listener) = @_;
    $self->{_listener} = $tcp_listener;
    return $self;
}

sub daemonizer {
    my ($self, $daemonizer) = @_;
    $self->{_daemonizer} = $daemonizer;
    return $self;
}

sub signal_handler {
    my ($self, $signal_handler) = @_;
    $self->{_signal_handler} = $signal_handler;
    return $self;
}

sub build {
    my $self = shift;

    my %components;

    for my $comp_name ( qw(
        event_dispatcher
        signal_handler     
        daemonizer
        listener
        context
    ) ) {

        my $prop = '_'.$comp_name;

        Ocean::Error::ParamNotFound->throw(
            message => sprintf(q{'%s' not found}, $comp_name)
        ) unless exists $self->{$prop};

        $components{$comp_name} = $self->{$prop};
    }

    return Ocean::Publisher::JSONRPC::Server->new(%components);
}

1;
