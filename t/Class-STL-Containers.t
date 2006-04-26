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
BEGIN { plan tests => 48 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list(qw(first second third fourth fifth));
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

$l->push_front($l->factory('sixth'));
ok ($l->front()->data(), "sixth", "list->push_front()");

$l->pop_front();
ok ($l->front()->data(), "first", "list->pop_front()");

$l->push_back($l->factory('seventh'));
ok ($l->back()->data(), "seventh", "list->push_back()");

$l->pop_back();
ok ($l->back()->data(), "fifth", "list->pop_back()"); # test-15

ok (join(' ', map($_->data(), $l->to_array())), "first second third fourth fifth", 'list->to_array()');

$f = $l->factory('eighth');
ok (ref($f), $l->data_type(), 'list->factory()');

my $i = $l->begin();
$l->insert($i, $l->factory('tenth'));
ok (join(' ', map($_->data(), $l->to_array())), "tenth first second third fourth fifth", 'list->insert()');
$i++;
$i++;
$l->insert($i, $l->factory('eleventh'));
ok (join(' ', map($_->data(), $l->to_array())), "tenth first second eleventh third fourth fifth", 'list->insert()');
$i = $l->end();
$l->insert($i, $l->factory('twelfth'));
#test 20
ok (join(' ', map($_->data(), $l->to_array())), "tenth first second eleventh third fourth twelfth fifth", 'list->insert()');

$l->erase($l->begin());
ok (join(' ', map($_->data(), $l->to_array())), "first second eleventh third fourth twelfth fifth", 'list->erase()');
$l->erase($l->end());
ok (join(' ', map($_->data(), $l->to_array())), "first second eleventh third fourth twelfth", 'list->erase()');

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
$l->insert($istart, $l->factory('tenth'), $l->factory('eleventh'));
ok ($l->size(), "2", 'list->insert()'); # test-25
ok (join(' ', map($_->data(), $l->to_array())), "tenth eleventh", 'list->insert(pos, element)');

my $l2 = list(qw(red blue yellow));
$l->insert($l->begin(), $l2->begin(), $l2->end());
ok (join(' ', map($_->data(), $l->to_array())), "red blue yellow tenth eleventh", 'list->insert(pos, start, finish)');

$l->insert($l->begin(), 3, $l->factory('repeated'));
ok (join(' ', map($_->data(), $l->to_array())), "repeated repeated repeated red blue yellow tenth eleventh", 'list->insert(pos, size, element)');

$l->swap($l2); ###############
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

my $l7 = $l3->clone();
$l7->pop();
ok (join(' ', map($_->data(), $l3->to_array())), "red blue yellow", 'overloaded = operator (append)');
ok (join(' ', map($_->data(), $l7->to_array())), "red blue", 'overloaded = operator (append)');

$l6->pop();
$l6->push_back($l6->factory('zebra'));
ok ($l6 != $l3, 1, 'overloaded <=> operator'); # $l6 is ne $l3;
# test-40
ok (join(' ', map($_->data(), $l6->to_array())), "red blue zebra", 'overloaded += operator (append)');

$l->clear();
ok ($l->size(), "0", 'list->clear()'); # test-46

$i = $l3->begin();
$i++;
my $l8 = vector($i);
ok (join(' ', map($_->data(), $l8->to_array())), "blue yellow", 'ctor(iterator-start)');

$l8->insert($l8->begin(), 3, $l8->factory('repeated'));
$start = $l8->begin();
$ifinish = $l8->end();
$start++;
$ifinish--;
my $l9 = vector($start, $ifinish);
ok (join(' ', map($_->data(), $l9->to_array())), "repeated repeated blue", 'ctor(iterator-start, iterator-finish)');

my $l10 = vector(data_type => 'MyElem');
$l10->push_back($l10->factory(name => 'one', data => '_one'));
$l10->push_back($l10->factory(name => 'two', data => '_two'));
$l10->push_back($l10->factory(name => 'three', data => '_three'));
ok (join(' ', map($_->name(), $l10->to_array())), "one two three", 'derived element');
ok (join(' ', map($_->data(), $l10->to_array())), "_one _two _three", 'derived element');

$start = $l10->begin();
$ifinish = $l10->end();
$start->p_element()->swap($ifinish->p_element());
ok (join(' ', map($_->name(), $l10->to_array())), "three two one", 'swap(element, element)');
ok (join(' ', map($_->data(), $l10->to_array())), "_three _two _one", 'swap(element, element)');

$l10->begin()->p_element()->data('BLUE');
ok (join(' ', map($_->data(), $l10->to_array())), "BLUE _two _one", 'set element');

ok ($l10->join(' '), "BLUE _two _one", 'join()');

{
	package MyElem;
	use base qw(Class::STL::Element);
	sub BEGIN { Class::STL::DataMembers->new( qw( name ) ); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
}
