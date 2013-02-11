use strict;
use warnings;

use inc::Module::Install;

name 'Ocean-Publisher';
all_from 'lib/Ocean/Publisher.pm';

requires(
    Ocean => '0.01',

    'AnyEvent::HTTPD'   => 0.93,
    'AnyEvent::JSONRPC' => 0.15,
);

tests_recursive('t');

author_tests('xt');

test_requires(
    #'Test::Class' => 0,
    'Test::More'                => 0,
    'Test::LoadAllModules'      => '',
    'TAP::Harness::JUnit'       => '',
);

install_script 'bin/ocean-jsonrpc';

auto_include;
WriteAll;
