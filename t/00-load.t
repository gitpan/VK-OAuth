#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'VK::OAuth' ) || print "Bail out!\n";
}

diag( "Testing VK::OAuth $VK::OAuth::VERSION, Perl $], $^X" );
