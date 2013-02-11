package Ocean::Publisher::JSONRPC::ProjectTemplate::Layout::File::Starter;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-jsonrpc-start' }

1;
__DATA__
#!/usr/bin/env perl

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}' if 0;

use strict;
use warnings;

use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::RealBin, '..', 'lib');
use lib File::Spec->catdir($FindBin::RealBin, '..', 'extlib');
use Getopt::Long;
use Pod::Usage;
use Ocean::Publisher::JSONRPC::Bootstrap;

my $help      = 0;
my $daemonize = 0;

GetOptions(
    'help|?'      => \$help,
    'daemonize|d' => \$daemonize,
);

pod2usage(1) if $help;

my $config_file = File::Spec->catfile($FindBin::RealBin, '..', 'config', 'ocean-jsonrpc.yml');

Ocean::Publisher::JSONRPC::Bootstrap->run( 
    config_file => $config_file ,
    daemonize   => $daemonize,
);

=head1 NAME 

ocean-jsonrpc-start - Ocean JSONRPC Publisher server starter

=head1 SYNOPSIS

    ./bin/ocean-jsonrpc-start

=cut
