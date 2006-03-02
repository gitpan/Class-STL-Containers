# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 5;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Containers;
BEGIN { plan tests => 2 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = Class::STL::Containers::List->new();
$l->push_back($l->factory(data => 'first'));
$l->push_back($l->factory(data => 'second'));
$l->push_back($l->factory(data => 'third'));
$l->push_back($l->factory(data => 'fourth'));
$l->push_back($l->factory(data => 'fifth'));

$l->remove_if($l->matches('^fi'));
ok (join('', $l->to_array()), "secondthirdfourth", 'matches()');

my $f = $l->factory(data=>'third');
$l->remove_if($l->equal_to($f));
ok (join('', $l->to_array()), "secondfourth", 'equal_to()');

my $l2 = Class::STL::Containers::List->new();
$l2->push_back($l2->factory(data => 100));
$l2->push_back($l2->factory(data => 103));
$l2->push_back($l2->factory(data => 106));
$l2->push_back($l2->factory(data => 108));
$l2->push_back($l2->factory(data => 120));

