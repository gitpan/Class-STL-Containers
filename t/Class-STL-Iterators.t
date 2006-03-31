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
use Class::STL::Utilities;
use Class::STL::Iterators;
BEGIN { plan tests => 20 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list();
$l->push_back($l->factory(data => 'red'));
$l->push_back($l->factory(data => 'blue'));
$l->push_back($l->factory(data => 'green'));
$l->push_back($l->factory(data => 'white'));
$l->push_back($l->factory(data => 'yellow'));

my $iter2 = $l->end();
$iter2--;
$iter2--;
my $iter1;
for ($iter1 = $l->begin(); $iter1 != $iter2; ++$iter1) {}
ok ($iter1->p_element()->data(), 'green', 'iterator->operator !=');
for ($iter1 = $l->begin(); $iter1 < $iter2; ++$iter1) {}
ok ($iter1->p_element()->data(), 'green', 'iterator->operator <');
for ($iter1 = $l->begin(); $iter1 <= $iter2; ++$iter1) {}
ok ($iter1->p_element()->data(), 'white', 'iterator->operator <=');

$iter2 = $l->begin();
$iter2++;
for ($iter1 = $l->end(); $iter1 != $iter2; --$iter1) {}
ok ($iter1->p_element()->data(), 'blue', 'iterator->operator !=');
for ($iter1 = $l->end(); $iter1 > $iter2; --$iter1) {}
ok ($iter1->p_element()->data(), 'blue', 'iterator->operator >');
for ($iter1 = $l->end(); $iter1 >= $iter2; --$iter1) {}
ok ($iter1->p_element()->data(), 'red', 'iterator->operator >=');

my $i = $l->begin();
ok ($i->p_element()->data(), 'red', 'iterator->first()');
$i = $i->next();
ok ($i->p_element()->data(), 'blue', 'iterator->next()');
$i = $i->next();
ok ($i->p_element()->data(), 'green', 'iterator->next()');
$i = $i->prev();
ok ($i->p_element()->data(), 'blue', 'iterator->prev()');
$i = $i->last();
ok ($i->p_element()->data(), 'yellow', 'iterator->last()');

my @data;
for (my $oi = $l->begin(); !$oi->at_end(); $oi++) {
	push(@data, $oi->p_element()->data());
}
ok (join('', @data), "redbluegreenwhiteyellow", "overloaded++");

@data = ();
for (my $oi = $l->end(); !$oi->at_start(); --$oi) {
	push(@data, $oi->p_element()->data());
}
ok (join('', @data), "yellowwhitegreenbluered", "overloaded--");

@data = ();
for (my $oi = $l->rbegin(); !$oi->at_end(); ++$oi) {
	push(@data, $oi->p_element()->data());
}
ok (join('', @data), "yellowwhitegreenbluered", "reverse overloaded++");

@data = ();
for (my $oi = $l->rend(); !$oi->at_end(); $oi--) {
	push(@data, $oi->p_element()->data());
}
ok (join('', @data), "redbluegreenwhiteyellow", "reverse overloaded--");

my $ri = reverse_iterator($l->rbegin());
ok ($ri->p_element()->data(), 'yellow', 'reverse_iterator->first()');
$ri->next();
ok ($ri->p_element()->data(), 'white', 'reverse_iterator->next()');
$ri->prev();
ok ($ri->p_element()->data(), 'yellow', 'reverse_iterator->prev()');
$ri->last();
ok ($ri->p_element()->data(), 'red', 'reverse_iterator->last()');

$ri = $l->begin();
$ri->next();
$ri->next();
my $ri2 = forward_iterator($ri);
ok ($ri2->p_element()->data(), 'green', 'iterator->next()');
