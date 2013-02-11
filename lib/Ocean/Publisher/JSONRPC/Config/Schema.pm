package Ocean::Publisher::JSONRPC::Config::Schema;

use strict;
use warnings;

use Ocean::Config::Schema::Log;
use Ocean::Config::Schema::TLS;

sub config {
    my $schema = {
        type => 'map', 
        mapping => {
            server => {
                type     => 'map',
                required => 1,
                mapping  => {
                    host          => { type => 'str', required => 1 }, 
                    port          => { type => 'int', required => 1 }, 
                    backlog       => { type => 'int', required => 1 }, 
                    timeout       => { type => 'int', required => 1 }, 
                    pid_file      => { type => 'str' }, 
                    context_class => { type => 'str' }, 
                },
            },
            event_handler => {
                type     => 'map',
                required => 1,
                mapping  => {
                    node       => { type => 'str', required => 0 }, 
                    authen     => { type => 'str', required => 0 }, 
                    connection => { type => 'str', required => 0 }, 
                    people     => { type => 'str', required => 0 },
                    pubsub     => { type => 'str', required => 0 },
                    message    => { type => 'str', required => 0 }, 
                    room       => { type => 'str', required => 0 }, 
                    p2p        => { type => 'str', required => 0 }, 
                },
            },
            log => Ocean::Config::Schema::Log->config,
            tls => Ocean::Config::Schema::TLS->config,
            handler => {
                type => 'any',
            },
        },
    };
    return $schema;
}

1;
