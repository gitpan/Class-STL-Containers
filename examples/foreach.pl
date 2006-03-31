#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>>:\n";
my $v = list(data_type => 'MyElem');
$v->push_back($v->factory(data => 'first'));
$v->push_back($v->factory(data => 'second'));
$v->push_back($v->factory(data => 'third'));
$v->push_back($v->factory(data => 'fourth'));
$v->push_back($v->factory(data => 'fifth'));
::foreach($v->begin(), $v->end(), MyPrint->new());
print 'Class::STL::Algorithms::foreach($v->begin(), $v->end(), MyUFunc->new());', "\n";
::foreach($v->begin(), $v->end(), MyUFunc->new());
::foreach($v->begin(), $v->end(), MyPrint->new());
print 'Class::STL::Algorithms::foreach($v->begin(), $v->end(), "something");', "\n";
::foreach($v->begin(), $v->end(), mem_fun('something'));

print "Static Foreach with mem_fun():\n";
::foreach($v->begin(), $v->end(), mem_fun('something'));
print "Static Foreach with unary-function-object:\n";
::foreach($v->begin(), $v->end(), MyPrint->new());

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
{
	package MyUFunc;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		$arg->data(uc($arg->data()));
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package MyElem;
	use base qw(Class::STL::Element);
	sub something
	{
		my $self = shift;
		print "Something:", $self->data(), "\n";
	}
}
# ----------------------------------------------------------------------------------------------------
