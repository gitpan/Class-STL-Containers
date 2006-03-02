#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>:\n";
my $p = Class::STL::Containers::PriorityQueue->new();
$p->push($p->factory(priority => 10, data => 'ten'));
$p->push($p->factory(priority => 2, data => 'two'));
$p->push($p->factory(priority => 12, data => 'twelve'));
$p->push($p->factory(priority => 3, data => 'three'));
$p->push($p->factory(priority => 11, data => 'eleven'));
$p->push($p->factory(priority => 1, data => 'one'));
$p->push($p->factory(priority => 1, data => 'one-2'));
$p->push($p->factory(priority => 12, data => 'twelve-2'));
$p->push($p->factory(priority => 20, data => 'twenty'), $p->factory(priority => 0, data => 'zero'));
print "Forward:\n";
my $i = $p->iterator()->first();
while (!$i->at_end())
{
	$i->p_element()->print(MyPrint->new('DATA:'));
	$i->next();
}
print "Backward:\n";
$i = $p->iterator()->last();
while (!$i->at_end())
{
	$i->p_element()->print(MyPrint->new('DATA:'));
	$i->prev();
}
print "Reverse:\n";
my $ri = Class::STL::Iterators::Reverse->new($p->iterator())->first();
while (!$ri->at_end())
{
	$ri->p_element()->print(MyPrint->new('DATA:'));
	$ri->next();
}
print "Compare:\n";
print '$ri->first() and $p->iterator()->last() are ', $ri->eq($p->iterator()) ? 'equal' : 'not equal', "\n";

my $i2 = Class::STL::Iterator->new($p->begin());
while ($i2->le($p->end()))
{
	$i2->p_element()->print(MyPrint->new('DATA:'));
	$i2->next();
}

# ----------------------------------------------------------------------------------------------------
{
	package MyPrint;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		print $self->arg(), $elem->data(), '[', $elem->priority(), ']', "\n";
	}
}
# ----------------------------------------------------------------------------------------------------
