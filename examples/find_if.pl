#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>>:\n";
my $v = list();
$v->push_back($v->factory(data => 'first'));
$v->push_back($v->factory(data => 'second'));
$v->push_back($v->factory(data => 'third'));
$v->push_back($v->factory(data => 'fourth'));
$v->push_back($v->factory(data => 'fifth'));
::foreach($v->begin(), $v->end(), MyPrint->new());
print "find_if(\$v->begin(), \$v->end(), MyFind->new(what => 'second'));\n";
print "Element 'second' was ", find_if($v->begin(), $v->end(), MyFind->new(what => 'second')) ? 'found' : 'not found', "\n";

# ----------------------------------------------------------------------------------------------------
{
	package MyFind;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub BEGIN { Class::STL::DataMembers->new( qw( what ) ); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		return $arg->data() eq $self->what() ? $arg : 0;
	}
}
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
