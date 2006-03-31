#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>>:\n";
my $l1 = list();
$l1->push_back($l1->factory(data => 'first'));
$l1->push_back($l1->factory(data => 'second'));
$l1->push_back($l1->factory(data => 'third'));
$l1->push_back($l1->factory(data => 'fourth'));
$l1->push_back($l1->factory(data => 'fifth'));
::foreach($l1->begin(), $l1->end(), MyPrint->new());
print "Size:", $l1->size(), "\n";
print "\$l1->begin:", $l1->begin()->p_element()->data(), "\n";
print "\$l1->end:", $l1->end()->p_element()->data(), "\n";
print "\$l1->rbegin:", $l1->rbegin()->p_element()->data(), "\n";
print "\$l1->rend:", $l1->rend()->p_element()->data(), "\n";
print "\$l1->front:", $l1->front()->data(), "\n";
print "\$l1->back:", $l1->back()->data(), "\n";
$l1->reverse();
print '$l1->reverse();', "\n";
::foreach($l1->begin(), $l1->end(), MyPrint->new());
print "\$l1->front:", $l1->front()->data(), "\n";
print "\$l1->back:", $l1->back()->data(), "\n";
print '$l1 container is ', $l1->empty() ? 'empty' : 'not empty', "\n";

print 'my $i = $l1->begin();', "\n";
print '$l1->insert($i, $l1->factory(data => "tenth"));', "\n";
print '$i++;', "\n";
print '$i++;', "\n";
print '$l1->insert($i, $l1->factory(data => "eleventh"));', "\n";
print '$i->last();', "\n";
print '$l1->insert($i, $l1->factory(data => \'twelfth\'));', "\n";
my $i = $l1->begin();
$l1->insert($i, $l1->factory(data => 'tenth'));
$i++;
$i++;
$l1->insert($i, $l1->factory(data => 'eleventh'));
$i->last();
$l1->insert($i, $l1->factory(data => 'twelfth'));
::foreach($l1->begin(), $l1->end(), MyPrint->new());

print '$l1->clear();', "\n";
$l1->clear();
print "Size:", $l1->size(), "\n";
print '$l1 container is ', $l1->empty() ? 'empty' : 'not empty', "\n";

# ----------------------------------------------------------------------------------------------------
{
	package MyPrint;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub function_operator
	{
		my $self = shift;
		my $element = shift;
		print "Data:", $element->data(), "\n";
	}
}
# ----------------------------------------------------------------------------------------------------
