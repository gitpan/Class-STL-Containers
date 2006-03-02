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
BEGIN { plan tests => 21 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = Class::STL::Containers::List->new();
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

$l->reverse();
ok ($l->front()->data(), "fifth", "list->reverse()");
ok ($l->back()->data(), "first", "list->reverse()");

$l->sort();
ok ($l->back()->data(), "third", "list->sort()");

$l->push_front($l->factory(data => 'sixth'));
ok ($l->front()->data(), "sixth", "list->push_front()");

$l->pop_front();
ok ($l->front()->data(), "fifth", "list->pop_front()");

$l->push_back($l->factory(data => 'seventh'));
ok ($l->back()->data(), "seventh", "list->push_back()");

$l->pop_back();
ok ($l->back()->data(), "third", "list->pop_back()");

ok (join('', $l->to_array()), "fifthfirstfourthsecondthird", 'list->to_array()');

$f = $l->factory(data=>'eighth');
ok (ref($f), $l->element_type(), 'list->factory()');

$l->swap($l->back(), $l->front());
ok (join('', $l->to_array()), "thirdfirstfourthsecondfifth", 'list->swap()');

$l->erase($l->find_if(MyFind->new('fourth')));
ok (join('', $l->to_array()), "thirdfirstsecondfifth", 'list->erase()');

$l->begin();
$l->insert($l->factory(data => 'tenth'));
$l->iterator()->next();
$l->iterator()->next();
$l->insert($l->factory(data => 'eleventh'));
ok (join('', $l->to_array()), "tenththirdeleventhfirstsecondfifth", 'list->erase()');

$l->clear();
ok ($l->size(), "0", 'list->clear()');

{
	package MyFind;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		return $elem->data() eq $self->arg() ? $elem : 0;
	}
}
