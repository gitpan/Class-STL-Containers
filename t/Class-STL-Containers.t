# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 26;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };
#BEGIN { use_ok('Class::STL::Iterators') };
#BEGIN { use_ok('Class::STL::Element') };

use Test;
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;
BEGIN { plan tests => 46 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list();
ok ($l->size(), "0", 'list->new()');

$l->push_back($l->factory(data => 'first'));
$l->push_back($l->factory(data => 'second'));
$l->push_back($l->factory(data => 'third'));
$l->push_back($l->factory(data => 'fourth'));
$l->push_back($l->factory(data => 'fifth'));
ok ($l->size(), "5", 'list->size()');

ok ($l->begin()->p_element()->data(), "first", "list->begin()");
ok ($l->end()->p_element()->data(), "fifth", "list->end()");
ok ($l->rbegin()->p_element()->data(), "fifth", "list->rbegin()");
ok ($l->rend()->p_element()->data(), "first", "list->rend()");
ok ($l->front()->data(), "first", "list->front()");
ok ($l->back()->data(), "fifth", "list->back()");
ok ($l->top()->data(), "fifth", "list->top()");

$l->reverse();
ok ($l->front()->data(), "fifth", "list->reverse()");	#test 10
ok ($l->back()->data(), "first", "list->reverse()");
$l->reverse();

$l->push_front($l->factory(data => 'sixth'));
ok ($l->front()->data(), "sixth", "list->push_front()");

$l->pop_front();
ok ($l->front()->data(), "first", "list->pop_front()");

$l->push_back($l->factory(data => 'seventh'));
ok ($l->back()->data(), "seventh", "list->push_back()");

$l->pop_back();
ok ($l->back()->data(), "fifth", "list->pop_back()"); # test-15

ok (join(' ', map($_->data(), $l->to_array())), "first second third fourth fifth", 'list->to_array()');

$f = $l->factory(data=>'eighth');
ok (ref($f), $l->data_type(), 'list->factory()');

my $i = $l->begin();
$l->insert($i, $l->factory(data => 'tenth'));
ok (join(' ', map($_->data(), $l->to_array())), "tenth first second third fourth fifth", 'list->insert()');
$i++;
$i++;
$l->insert($i, $l->factory(data => 'eleventh'));
ok (join(' ', map($_->data(), $l->to_array())), "tenth first eleventh second third fourth fifth", 'list->insert()');
$i = $l->end();
$l->insert($i, $l->factory(data => 'twelfth'));
#test 20
ok (join(' ', map($_->data(), $l->to_array())), "tenth first eleventh second third fourth twelfth fifth", 'list->insert()');

$l->erase($l->begin());
ok (join(' ', map($_->data(), $l->to_array())), "first eleventh second third fourth twelfth fifth", 'list->erase()');
$l->erase($l->end());
ok (join(' ', map($_->data(), $l->to_array())), "first eleventh second third fourth twelfth", 'list->erase()');

my $istart = $l->begin();
my $ifinish = $l->end();
$istart++;
$ifinish--;
$l->erase($istart, $ifinish);
ok (join(' ', map($_->data(), $l->to_array())), "first twelfth", 'list->erase(start, finish)');

$istart = $l->begin();
$ifinish = $l->end();
$l->erase($istart, $ifinish);
ok (join('', map($_->data(), $l->to_array())), "", 'list->erase(start, finish)');

$istart = $l->begin();
$l->insert($istart, $l->factory(data => 'tenth'), $l->factory(data => 'eleventh'));
ok ($l->size(), "2", 'list->insert()'); # test-25
ok (join(' ', map($_->data(), $l->to_array())), "tenth eleventh", 'list->insert(pos, element)');

my $l2 = list();
$l2->push_back($l2->factory(data => 'red'));
$l2->push_back($l2->factory(data => 'blue'));
$l2->push_back($l2->factory(data => 'yellow'));
$l->insert($l->begin(), $l2->begin(), $l2->end());
ok (join(' ', map($_->data(), $l->to_array())), "red blue yellow tenth eleventh", 'list->insert(pos, start, finish)');

$l->insert($l->begin(), 3, $l->factory(data => 'repeated'));
ok (join(' ', map($_->data(), $l->to_array())), "repeated repeated repeated red blue yellow tenth eleventh", 'list->insert(pos, size, element)');

$l->swap($l2);
ok (join(' ', map($_->data(), $l->to_array())), "red blue yellow", 'list->swap()');
# test-30
ok (join(' ', map($_->data(), $l2->to_array())), "repeated repeated repeated red blue yellow tenth eleventh", 'list->swap()');

my $l3 = vector($l);
ok (join(' ', map($_->data(), $l3->to_array())), "red blue yellow", 'copy ctor(container)');

my $l4 = vector($l3->begin());
ok (join(' ', map($_->data(), $l4->to_array())), "red blue yellow", 'copy ctor(iterator-start)');

$istart = $l4->begin();
$istart++;
my $l5 = vector($istart, $l4->end());
ok (join(' ', map($_->data(), $l5->to_array())), "blue yellow", 'copy ctor(iterator-start, iterator-finish)');

$l4 += $l4;
ok (join(' ', map($_->data(), $l4->to_array())), "red blue yellow red blue yellow", 'overloaded += operator (append)');

my $l6 = $l3->clone();
# test-35
ok ($l6 == $l3, 1, 'overloaded == operator');
ok ($l6 != $l3, 0, 'overloaded != operator');
ok ($l6 > $l3, 0, 'overloaded > operator');
ok ($l6 < $l3, 0, 'overloaded < operator');
ok ($l6 >= $l3, 1, 'overloaded >= operator');
ok ($l6 <= $l3, 1, 'overloaded <= operator'); # test-40
ok ($l6 <=> $l3, 0, 'overloaded <=> operator');

my $l7 = $l3->clone();
$l7->pop();
ok (join(' ', map($_->data(), $l3->to_array())), "red blue yellow", 'overloaded = operator (append)');
ok (join(' ', map($_->data(), $l7->to_array())), "red blue", 'overloaded = operator (append)');

$l6->pop();
$l6->push_back($l6->factory(data => 'zebra'));
ok ($l6 <=> $l3, 1, 'overloaded <=> operator'); # $l6 is gt $l3;
# test-45
ok (join(' ', map($_->data(), $l6->to_array())), "red blue zebra", 'overloaded += operator (append)');

$l->clear();
ok ($l->size(), "0", 'list->clear()'); # test-46

{
	package MyFind;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub BEGIN { Class::STL::DataMembers->new( qw( what ) ); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		return $arg->data() eq $self->what() ? $arg : 0;
	}
}
