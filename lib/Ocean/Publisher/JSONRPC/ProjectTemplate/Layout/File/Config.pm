package Ocean::Publisher::JSONRPC::ProjectTemplate::Layout::File::Config;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-publisher.yml'        }

1;
__DATA__
---
server:
  host: 192.168.0.1
  port: 3478
  backlog: 1024
  timeout: 300
  pid_file: __path_to(<: $layout.relative_path_for('run_dir') :>/ocean_publisher.pid)__
  context_class: <: $context.get('context_class') :>

event_handler:
  pubsub:     <: $context.get('handler_class') :>::PubSub

log:
  type: print
  formatter: color
  level: info
  filepath: __path_to(<: $layout.relative_path_for('log_dir') :>/ocean_publisher.log)__

#tls:
#  cert_file: __path_to(<: $layout.relative_path_for('cert_pem') :>)__
#  key_file: __path_to(<: $layout.relative_path_for('cert_key') :>)__
#  cipher_list: ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP:+eNULL

handler:
  node_id: publisher01
  serializer: json
  router: __path_to(<: $layout.relative_path_for('config_dir') :>/router.pl)__
  dispatcher:
    class: Ocean::Cluster::Frontend::Dispatcher::Gearman
    config:
        servers:
            - 192.168.0.2:7001
            - 192.168.0.2:7002
            - 192.168.0.2:7003
            - 192.168.0.2:7004

