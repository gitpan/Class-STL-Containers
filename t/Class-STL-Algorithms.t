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
use Class::STL::DataMembers;
BEGIN { plan tests => 57 }

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
transform($l->begin(), $l->end(), $l2->begin(), ptr_fun('uc'));
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

sub mybfun { return $_[0] . '-' . $_[1]; }

$l2 = list(qw( 1 2 3 4 ));
ok (join(' ', map($_->data(), $l2->to_array())), "1 2 3 4", 'generator()');

generate($l2->begin(), $l2->end(), MyGenerator->new());
ok (join(' ', map($_->data(), $l2->to_array())), "2 4 8 16", 'generator()');

generate_n($l2->begin(), 3, MyGenerator->new(counter => 4));
ok (join(' ', map($_->data(), $l2->to_array())), "8 16 32 16", 'generator_n()');

fill($l2->begin(), $l2->end(), 99);
ok (join(' ', map($_->data(), $l2->to_array())), "99 99 99 99", 'fill()');

fill_n($l2->begin(), 1, 9);
ok (join(' ', map($_->data(), $l2->to_array())), "9 99 99 99", 'fill_n()');

my $l4 = list($l2);
ok (equal($l2->begin(), $l2->end(), $l4->begin()), "1", 'equal()');
ok (join(' ', map($_->data(), $l4->to_array())), "9 99 99 99", 'copy');
ok (equal($l2->begin(), $l2->end(), $l4->begin(), MyBinFun->new()), "1", 'equal(...binary_op)');

fill($l4->begin(), $l4->begin(), 0);
ok (equal($l2->begin(), $l2->end(), $l4->begin()), "0", '!equal()');
ok (equal($l2->begin(), $l2->end(), $l4->begin(), MyBinFun->new()), "0", '!equal(...binary_op)');

fill_n($l2->begin(), 1, 0);
ok (equal($l2->begin(), $l2->end(), $l4->begin()), "1", 'equal()');

$l4 = list(qw(1 2 3 4 5 6 7));
$i = $l4->begin();
$i++;
$i++;
reverse($i, $l4->end());
ok (join(' ', map($_->data(), $l4->to_array())), "1 2 7 6 5 4 3", 'reverse()');

reverse($l4->begin(), $i);
ok (join(' ', map($_->data(), $l4->to_array())), "7 2 1 6 5 4 3", 'reverse()');

$l2->clear();
reverse_copy($l4->begin(), $l4->end(), $l2->begin());
ok (join(' ', map($_->data(), $l2->to_array())), "3 4 5 6 1 2 7", 'reverse_copy()');

$l2->clear();
$i = $l4->end();
--$i;
--$i;
reverse_copy($l4->begin(), $i, $l2->begin());
ok (join(' ', map($_->data(), $l2->to_array())), "5 6 1 2 7", 'reverse_copy()');

$i = $l2->begin();
++$i;
++$i;
rotate($l2->begin(), $i, $l2->end());
ok (join(' ', map($_->data(), $l2->to_array())), "1 2 7 5 6", 'rotate()');

$l2->clear();
$l4 = list(qw(1 2 3 4 5 6 7));
$i = $l4->begin();
$i++;
$i++;
rotate_copy($l4->begin(), $i, $l4->end(), $l2->begin());
ok (join(' ', map($_->data(), $l2->to_array())), "3 4 5 6 7 1 2", 'rotate_copy()');

stable_partition($l2->begin(), $l2->end(), is_even->new());
ok (join(' ', map($_->data(), $l2->to_array())), "4 6 2 3 5 7 1", 'stable_partition()');

ok (min_element($l2->begin(), $l2->end())->p_element()->data(), "1", 'min_element() -- 1');
ok (min_element($l2->begin(), $l2->end(), less())->p_element()->data(), "1", 'min_element() -- 2');

ok (max_element($l2->begin(), $l2->end())->p_element()->data(), "7", 'max_element() -- 1');
ok (max_element($l2->begin(), $l2->end(), less())->p_element()->data(), "7", 'max_element() -- 2');

$l2 = list(qw(4 5 5 9 -1 -1 -1 3 7 5 5 5 6 7 7 7 4 2 1 1));
unique($l2->begin(), $l2->end());
ok (join(' ', map($_->data(), $l2->to_array())), "4 5 9 -1 3 7 5 6 7 4 2 1", 'unique() -- 1');

$l2 = list(qw(4 5 5 9 -1 -1 -1 3 7 5 5 5 6 7 7 7 4 2 1 1));
unique($l2->begin(), $l2->end(), equal_to());
ok (join(' ', map($_->data(), $l2->to_array())), "4 5 9 -1 3 7 5 6 7 4 2 1", 'unique() -- 2');
unique($l2->begin(), $l2->end(), equal_to());
ok (join(' ', map($_->data(), $l2->to_array())), "4 5 9 -1 3 7 5 6 7 4 2 1", 'unique() -- 2');

$l2 = list(qw(4 5 5 9 -1 -1 -1 3 7 5 5 5 6 7 7 7 4 2 1 1));
$l3->clear();
unique_copy($l2->begin(), $l2->end(), $l3->begin());
ok (join(' ', map($_->data(), $l3->to_array())), "4 5 9 -1 3 7 5 6 7 4 2 1", 'unique_copy() -- 1');

$l3->clear();
unique_copy($l2->begin(), $l2->end(), $l3->begin(), equal_to());
ok (join(' ', map($_->data(), $l3->to_array())), "4 5 9 -1 3 7 5 6 7 4 2 1", 'unique_copy() -- 2');

ok (adjacent_find($l2->begin(), $l2->end())->arr_idx(), "1", 'adjacent_find() -- 1');
ok (adjacent_find($l2->begin(), $l2->end(), equal_to())->arr_idx(), "1", 'adjacent_find() -- 2');

{
  package is_even;
  use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
  sub function_operator
  {
    my $self = shift;
    my $arg1 = shift;
    return $arg1->data() % 2 == 0;
  }
}
{
  package MyBinFun;
  use base qw(Class::STL::Utilities::FunctionObject::BinaryFunction);
  sub function_operator
  {
    my $self = shift;
    my $arg1 = shift;
    my $arg2 = shift;
    return $arg1->eq($arg2);
  }
}
  
{
  package MyGenerator;
  use base qw(Class::STL::Utilities::FunctionObject::Generator);
  sub BEGIN { Class::STL::DataMembers->new(qw( counter )); }
  sub new
  {
    my $self = shift;
    my $class = ref($self) || $self;
    $self = $class->SUPER::new(@_);
    bless($self, $class);
    $self->members_init(counter => 1, @_);
    return $self;
  }
  sub function_operator
  {
    my $self = shift;
    $self->counter($self->counter() *2);
    return Class::STL::Element->new($self->counter());
  }
}
