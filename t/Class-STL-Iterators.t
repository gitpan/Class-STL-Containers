# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 14;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };
#BEGIN { use_ok('Class::STL::Iterators') };
#BEGIN { use_ok('Class::STL::Element') };

use Test;
use Class::STL::Containers;
BEGIN { plan tests => 9 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = Class::STL::Containers::List->new();
$l->push_back($l->factory(data => 'red'));
$l->push_back($l->factory(data => 'blue'));
$l->push_back($l->factory(data => 'green'));
$l->push_back($l->factory(data => 'white'));
$l->push_back($l->factory(data => 'yellow'));
my $i = $l->iterator()->first();
ok ($i->p_element()->data(), 'red', 'iterator->first()');
$i = $i->next();
ok ($i->p_element()->data(), 'blue', 'iterator->next()');
$i = $i->next();
ok ($i->p_element()->data(), 'green', 'iterator->next()');
$i = $i->prev();
ok ($i->p_element()->data(), 'blue', 'iterator->prev()');
$i = $i->last();
ok ($i->p_element()->data(), 'yellow', 'iterator->last()');

my $ri = Class::STL::Iterators::Reverse->new($l->iterator())->first();
ok ($ri->p_element()->data(), 'yellow', 'reverse_iterator->first()');
$ri->next();
ok ($ri->p_element()->data(), 'white', 'reverse_iterator->next()');
$ri->prev();
ok ($ri->p_element()->data(), 'yellow', 'reverse_iterator->prev()');
$ri->last();
ok ($ri->p_element()->data(), 'red', 'reverse_iterator->last()');
