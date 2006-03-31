#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>>:\n";
my $d1 = deque();
print "Deque-1:\n";
$d1->push_back($d1->factory(data => 'first'));
$d1->push_back($d1->factory(data => 'second'));
$d1->push_back($d1->factory(data => 'third'));
$d1->push_back($d1->factory(data => 'fourth'));
$d1->push_back($d1->factory(data => 'fifth'));
::foreach($d1->begin(), $d1->end(), MyPrint->new());

my $d2 = deque($d1);
print "Deque-2:\n";
::foreach($d1->begin(), $d1->end(), MyPrint->new());

print "Deques d1 and d2 are ", ($d1->eq($d2) ? " equal" : " not equal"). "\n";
$d2->push($d2->factory(data => 'sixth'));
print '$d2->push($d2->factory(data => "sixth"));', "\n";
print "Deques d1 and d2 are ", ($d1->eq($d2) ? " equal" : " not equal"). "\n";


# ----------------------------------------------------------------------------------------------------
{
	package MyPrint;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		print "Data:", $arg->data(), "\n";
	}
}
# ----------------------------------------------------------------------------------------------------
