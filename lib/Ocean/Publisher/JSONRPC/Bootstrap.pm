package Ocean::Publisher::JSONRPC::Bootstrap;

use strict;
use warnings;

use parent 'Ocean::Bootstrap';

use Ocean::Publisher::JSONRPC::Config::Schema;
use Ocean::Publisher::JSONRPC::ServerFactory;

sub config_schema  { Ocean::Publisher::JSONRPC::Config::Schema->config }
sub server_factory { Ocean::Publisher::JSONRPC::ServerFactory->new     }

1;
