#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>:\n";
my $l1 = Class::STL::Containers::List->new();
$l1->push_back($l1->factory(data => 'first'));
$l1->push_back($l1->factory(data => 'second'));
$l1->push_back($l1->factory(data => 'third'));
$l1->push_back($l1->factory(data => 'fourth'));
$l1->push_back($l1->factory(data => 'fifth'));
$l1->foreach(MyPrint->new('DATA:'));
print "Size:", $l1->size(), "\n";
print "\$l1->begin:", $l1->begin()->p_element()->data(), "\n";
print "\$l1->end:", $l1->end()->p_element()->data(), "\n";
print "\$l1->rbegin:", $l1->rbegin()->p_element()->data(), "\n";
print "\$l1->rend:", $l1->rend()->p_element()->data(), "\n";
print "\$l1->front:", $l1->front()->data(), "\n";
print "\$l1->back:", $l1->back()->data(), "\n";
$l1->reverse();
print '$l1->reverse();', "\n";
$l1->foreach(MyPrint->new('DATA:'));
print "\$l1->front:", $l1->front()->data(), "\n";
print "\$l1->back:", $l1->back()->data(), "\n";
print '$l1 container is ', $l1->empty() ? 'empty' : 'not empty', "\n";

print '$l1->begin();', "\n";
print '$l1->insert($l1->factory(data => "tenth"));', "\n";
print '$l1->iterator()->next();', "\n";
print '$l1->iterator()->next();', "\n";
print '$l1->insert($l1->factory(data => "eleventh"));', "\n";
$l1->begin();
$l1->insert($l1->factory(data => 'tenth'));
$l1->iterator()->next();
$l1->iterator()->next();
$l1->insert($l1->factory(data => 'eleventh'));
$l1->foreach(MyPrint->new('DATA:'));

print '$l1->clear();', "\n";
$l1->clear();
print "Size:", $l1->size(), "\n";
print '$l1 container is ', $l1->empty() ? 'empty' : 'not empty', "\n";

# ----------------------------------------------------------------------------------------------------
{
	package MyPrint;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		print $self->arg(), $elem->data(), "\n";
	}
}
# ----------------------------------------------------------------------------------------------------
