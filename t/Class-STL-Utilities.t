# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 5;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;
BEGIN { plan tests => 22 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list(qw(first second third fourth fifth));

remove_if($l->begin(), $l->end(), bind2nd(matches(), '^fi'));
ok (join('', map($_->data(), $l->to_array())), "secondthirdfourth", 'matches()');

my $f = $l->factory('third');
remove_if($l->begin(), $l->end(), bind1st(equal_to(), $f));
ok (join('', map($_->data(), $l->to_array())), "secondfourth", 'equal_to()');

{
	package MyClass;
	use base qw(Class::STL::Element);
}
my $e = MyClass->new(data => 100, data_type => 'numeric');
my $e2 = MyClass->new($e);
my $e3 = MyClass->new(data => 101, data_type => 'numeric');
ok (equal_to()->function_operator($e, $e2), "1", "equal_to()");
ok (not_equal_to()->function_operator($e, $e2), "", "not_equal_to()");
ok (greater()->function_operator($e3, $e2), "1", "greater()"); # $e3 > $e2
ok (less()->function_operator($e2, $e3), "1", "less()"); # $e2 < $e3
ok (greater_equal()->function_operator($e3, $e2), "1", "greater_equal()");
ok (less_equal()->function_operator($e2, $e3), "1", "less_equal()");
ok (compare()->function_operator($e2, $e3), "-1", "compare()"); # $e2 < $e3
ok (compare()->function_operator($e3, $e), "1", "compare()"); # $e3 > $e
ok (compare()->function_operator($e2, $e), "0", "compare()");

$l2 = list(qw(1 2 3 4 5));
$e2 = $l2->factory(2);
ok (count_if($l2->begin(), $l2->end(), bind2nd(greater(), $e2)), "3", 'bind2nd()');
ok (count_if($l2->begin(), $l2->end(), bind1st(greater(), $e2)), "1", 'bind1st()');
ok (count_if($l2->begin(), $l2->end(), bind2nd(greater(), 2)), "3", 'bind2nd()');
ok (count_if($l2->begin(), $l2->end(), bind1st(greater(), 2)), "1", 'bind1st()');

my $l3 = list();
transform($l2->begin(), $l2->end(), $l3->begin(), bind2nd(multiplies(), 2));
ok (join(' ', map($_->data(), $l3->to_array())), "2 4 6 8 10", 'multiplies()');

my $l4 = list();
transform($l3->begin(), $l3->end(), $l4->begin(), bind2nd(minus(), 1));
ok (join(' ', map($_->data(), $l4->to_array())), "1 3 5 7 9", 'minus()');

$l4->clear();
transform($l3->begin(), $l3->end(), $l4->begin(), bind2nd(plus(), 1));
ok (join(' ', map($_->data(), $l4->to_array())), "3 5 7 9 11", 'plus()');

$l4->clear();
transform($l3->begin(), $l3->end(), $l4->begin(), bind2nd(divides(), 2));
ok (join(' ', map($_->data(), $l4->to_array())), "1 2 3 4 5", 'divides()');

$l4->clear();
transform($l3->begin(), $l3->end(), $l4->begin(), bind2nd(modulus(), 3));
ok (join(' ', map($_->data(), $l4->to_array())), "2 1 0 2 1", 'modulus()');

my $l5 = list();
transform($l3->begin(), $l3->end(), $l4->begin(), $l5->begin(), logical_and());
ok (join(' ', map($_->data(), $l5->to_array())), "1 1 0 1 1", 'logical_and()');

$l5->clear();
transform($l3->begin(), $l3->end(), $l4->begin(), $l5->begin(), logical_or());
ok (join(' ', map($_->data(), $l5->to_array())), "1 1 1 1 1", 'logical_or()');
