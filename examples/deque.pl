#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>>:\n";
my $d = deque();
$d->push_back($d->factory(data => 'first'));
$d->push_back($d->factory(data => 'second'));
$d->push_back($d->factory(data => 'third'));
$d->push_back($d->factory(data => 'fourth'));
$d->push_back($d->factory(data => 'fifth'));
::foreach($d->begin(), $d->end(), MyPrint->new());
print '$d->push_front($d->factory(data => \'seventh\'));', "\n";
$d->push_front($d->factory(data => 'seventh'));
::foreach($d->begin(), $d->end(), MyPrint->new());
$d->pop_front();
print '$d->pop_front();', "\n";
::foreach($d->begin(), $d->end(), MyPrint->new());
$d->pop_back();
print '$d->pop_back();', "\n";
::foreach($d->begin(), $d->end(), MyPrint->new());
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
