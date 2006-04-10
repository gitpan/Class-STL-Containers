# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 6;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;
BEGIN { plan tests => 28 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list(qw(first second third fourth fifth));
ok (find_if($l->begin(), $l->end(), bind1st(equal_to(), 'fifth'))->p_element()->data(), 'fifth', 'find_if()');
my $i = find_if($l->begin(), $l->end(), bind1st(equal_to(), 'third'));
ok ($i->p_element()->data(), 'third', 'find_if()');

ok (count_if($l->begin(), $l->end(), bind2nd(matches(), '^f\w+h$')), "2", 'count_if()');

my $erx = $l->factory('^FI');
ok (count_if($l->begin(), $l->end(), bind2nd(matches_ic(), $erx)), "2", 'regex()');

$l2 = list();
transform($l->begin(), $l->end(), $l2->begin(), ptr_fun('lc'));
$l2 = list();
transform($l->begin(), $l->end(), $l2->begin(), ptr_fun('uc')); # test repeated calls to ptr_fun()
ok (join(' ', map($_->data(), $l->to_array())), "first second third fourth fifth", 'transform_1()');
ok (join(' ', map($_->data(), $l2->to_array())), "FIRST SECOND THIRD FOURTH FIFTH", 'transform_1()');

$l2 = list(1, 2, 3, 4, 5);
my $e2 = $l2->factory(2);
ok (count_if($l2->begin(), $l2->end(), bind2nd(greater(), $e2)), "3", 'count_if() with bind2nd()');
ok (count_if($l2->begin(), $l2->end(), bind1st(greater(), $e2)), "1", 'count_if() with bind1st()');
ok (count_if($l2->begin(), $l2->end(), bind2nd(greater(), 2)), "3", 'count_if() with bind2nd()');

$l3 = list();
transform($l->begin(), $l->end(), $l2->begin(), $l3->begin(), ptr_fun_binary('::mybfun'));
$l3 = list();
transform($l->begin(), $l->end(), $l2->begin(), $l3->begin(), ptr_fun_binary('::mybfun'));
ok (join(' ', map($_->data(), $l->to_array())), "first second third fourth fifth", 'transform_2()');
ok (join(' ', map($_->data(), $l2->to_array())), "1 2 3 4 5", 'transform_2()');
ok (join(' ', map($_->data(), $l3->to_array())), "first-1 second-2 third-3 fourth-4 fifth-5", 'transform_2()');

my $e6 = $l->factory('sixth');
$l->push_front($e6);
ok (find($l->begin(), $l->end(), $e6)->p_element()->data(), "sixth", 'find()');
remove($l->begin(), $l->end(), $e6);
$l->push_back($e6);
ok (find($l->begin(), $l->end(), $e6)->p_element()->data(), "sixth", 'find()');

remove($l->begin(), $l->end(), $e6);
ok (join(' ', map($_->data(), $l->to_array())), "first second third fourth fifth", 'remove()');

$l->push_back($e6, $e6);
$l->push_front($e6, $e6);
ok (join(' ', map($_->data(), $l->to_array())), "sixth sixth first second third fourth fifth sixth sixth", 'push_back/front()');

ok (count($l->begin(), $l->end(), $e6), "4", 'count()');

my $e7 = $l->factory('seventh');
replace($l->begin(), $l->end(), $e6, $e7);
ok (join(' ', map($_->data(), $l->to_array())), "seventh seventh first second third fourth fifth seventh seventh", 'replace()');

replace_if($l->begin(), $l->end(), bind2nd(equal_to(), $e7), $e6);
ok (join(' ', map($_->data(), $l->to_array())), "sixth sixth first second third fourth fifth sixth sixth", 'replace_if()');

$l2->clear();
replace_copy($l->begin(), $l->end(), $l2->begin(), $e6, $e7);
ok (join(' ', map($_->data(), $l2->to_array())), "seventh seventh first second third fourth fifth seventh seventh", 'replace_copy()');

$l2->clear();
replace_copy_if($l->begin(), $l->end(), $l2->begin(), bind1st(equal_to(), $e6), $e7);
ok (join(' ', map($_->data(), $l2->to_array())), "seventh seventh first second third fourth fifth seventh seventh", 'replace_copy_if()');

$l2->clear();
remove_copy($l->begin(), $l->end(), $l2->begin(), $e6);
ok (join(' ', map($_->data(), $l2->to_array())), "first second third fourth fifth", 'remove_copy()');

$l2->clear();
remove_copy_if($l->begin(), $l->end(), $l2->begin(), bind1st(equal_to(), $e6));
ok (join(' ', map($_->data(), $l2->to_array())), "first second third fourth fifth", 'remove_copy_if()');

$l2->clear();
copy_backward($l->begin(), $l->end(), $l2->begin());
ok (join(' ', map($_->data(), $l2->to_array())), "sixth sixth fifth fourth third second first sixth sixth", 'copy_backward()');

ok (find($l2->begin(), $l2->end(), $e6)->p_element()->data(), 'sixth', 'find()');

$l2->clear();
copy($l->begin(), $l->end(), $l2->begin());
ok (join(' ', map($_->data(), $l2->to_array())), "sixth sixth first second third fourth fifth sixth sixth", 'copy()');
ok (join(' ', map($_->data(), $l->to_array())), "sixth sixth first second third fourth fifth sixth sixth", 'copy()');

remove_if($l2->begin(), $l2->end(), bind2nd(matches(), '^fi'));
ok (join(' ', map($_->data(), $l2->to_array())), "sixth sixth second third fourth sixth sixth", 'remove_if()');

sub mybfun
{
	return $_[0] . '-' . $_[1];
}
