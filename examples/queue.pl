#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>:\n";
my $v = queue();
$v->push($v->factory(data => 'first'));
$v->push($v->factory(data => 'second'));
$v->push($v->factory(data => 'third'));
$v->push($v->factory(data => 'fourth'));
$v->push($v->factory(data => 'fifth'));

::foreach($v->begin(), $v->end(), MyPrint->new());
print "Back:"; MyPrint->new()->function_operator($v->back());
print "Front:"; MyPrint->new()->function_operator($v->front());
print '$v->pop();', "\n";
print '$v->push($v->factory(data => "sixth"));', "\n";
$v->pop();
$v->push($v->factory(data => 'sixth'));
print "Back:"; MyPrint->new()->function_operator($v->back());
print "Front:"; MyPrint->new()->function_operator($v->front());

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
