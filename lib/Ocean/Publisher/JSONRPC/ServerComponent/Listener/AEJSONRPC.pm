package Ocean::Publisher::JSONRPC::ServerComponent::Listener::AEJSONRPC;

use strict;
use warnings;

use parent 'Ocean::Publisher::JSONRPC::ServerComponent::Listener';

use Ocean::Config;
use Ocean::Util::Config qw(value_is_true); 
use Ocean::Util::TLS;

use AnyEvent::JSONRPC::HTTP::Server;
use Log::Minimal;

sub start {
    my $self = shift;

    $self->{_listener} = AnyEvent::JSONRPC::HTTP::Server->new(
        host    => $self->{_host},
        port    => $self->{_port},
        # TODO only params above are supported by AE:J:H:S
        # backlog => $self->{_backlog},
        # timeout => $self->{_timeout},
        # tls_ctx => Ocean::Config->instance->get('tls');
    );
    $self->{_listener}->reg_cb(
        publish => sub {
            my ($res_cv, @params) = @_;
            $self->_on_publish_request($res_cv, \@params);
        }
    );

    $self->{_delegate}->on_listener_prepare($self->{_host}, $self->{_port});
}

sub _on_publish_request {
    my ($self, $res_cv, $params) = @_;

    infof("<Server> here comes new publish request");
    $self->{_delegate}->on_publish_request($res_cv, $params)
}

sub stop {
    my $self = shift;
    delete $self->{_listener}
        if $self->{_listener};
}

1;
