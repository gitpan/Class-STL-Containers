# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 5;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Element;
BEGIN { plan tests => 13 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $e = Class::STL::Element->new(data => "hello", data_type => 'string');
ok ($e->data(), "hello", "ctor");

my $e2 = Class::STL::Element->new($e);
ok ($e2->eq($e), 1, "copy ctor");
ok ($e2->ne($e), "", "copy ctor");

my $e3 = Class::STL::Element->new(data => 100, data_type => 'numeric');
my $e4 = Class::STL::Element->new(data => 103, data_type => 'numeric');
my $e5 = Class::STL::Element->new(data => 103, data_type => 'numeric');
ok ($e3->eq($e4), "", "eq()");
ok ($e4->eq($e5), "1", "eq()");
ok ($e3->ne($e4), "1", "ne()");
ok ($e3->lt($e4), "1", "lt()");
ok ($e3->gt($e4), "", "gt()");
ok ($e3->le($e4), "1", "le()");
ok ($e3->ge($e4), "", "ge()");
ok ($e3->cmp($e4), "-1", "cmp()");
ok ($e4->cmp($e3), "1", "cmp()");
ok ($e4->cmp($e5), "0", "cmp()");
