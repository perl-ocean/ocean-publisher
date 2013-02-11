package Ocean::Publisher::JSONRPC::ServerComponentFactory;

use strict;
use warnings;

use Module::Load ();

use Ocean::EventDispatcher;
use Ocean::ServerComponent::Daemonizer::Default;
use Ocean::ServerComponent::Daemonizer::Null;
use Ocean::CommonComponent::SignalHandler::AESignal;
use Ocean::Publisher::JSONRPC::ServerComponent::Listener::AEJSONRPC;

sub new { bless {}, $_[0] }

sub create_context {
    my ($self, $config) = @_;
    my $context_class = $config->get(server => 'context_class')
        || 'Ocean::Publisher::JSONRPC::Context';
    
    Module::Load::load($context_class);

    my $context = $context_class->new;
    unless ($context && $context->isa('Ocean::Publisher::JSONRPC::Context')) {
        die "Context Class is not a subclass of Ocean::Publisher::JSONRPC::Context";
    }
    return $context;
}

sub create_event_dispatcher {
    my ($self, $config) = @_;

    my $dispatcher = Ocean::EventDispatcher->new;
    my $handlers = $config->get('event_handler');

    for my $category ( keys %$handlers ) {
        my $handler_class = $handlers->{$category};
        Module::Load::load($handler_class);
        my $handler = $handler_class->new;
        $dispatcher->register_handler($category, $handler);
    }
    return $dispatcher;
}

sub create_signal_handler {
    my ($self, $config) = @_;
    return Ocean::CommonComponent::SignalHandler::AESignal->new;
}

sub create_daemonizer {
    my ($self, $config, $daemonize) = @_;

    my $pid_file = $config->get(server => q{pid_file});

    if ($daemonize && !$pid_file) {
        die "'pid_file' not found. "
            . "To daemonize process, you need to add 'pid_file' "
            . "setting on your config file.";
    }
    my $daemonizer = $daemonize
        ? Ocean::ServerComponent::Daemonizer::Default->new( pid_file => $pid_file )
        : Ocean::ServerComponent::Daemonizer::Null->new();
    return $daemonizer;
}

sub create_listener {
    my ($self, $config) = @_;
    return Ocean::Publisher::JSONRPC::ServerComponent::Listener::AEJSONRPC->new(
        host            => $config->get(server => q{host}),
        port            => $config->get(server => q{port}),
        backlog         => $config->get(server => q{backlog}),
        timeout         => $config->get(server => q{timeout}),
    );
}

1;
