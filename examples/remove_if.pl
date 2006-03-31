#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;

print ">>>$0>>>\n";
my $v = list();
$v->push_back($v->factory(data => 'first'));
$v->push_back($v->factory(data => 'second'));
$v->push_back($v->factory(data => 'third'));
$v->push_back($v->factory(data => 'fourth'));
$v->push_back($v->factory(data => 'fifth'));
::foreach($v->begin(), $v->end(), MyPrint->new());

print 'remove_if($v->begin(), $v->end(), bind1st(equal_to(), $v->back()));', "\n";
remove_if($v->begin(), $v->end(), bind1st(equal_to(), $v->back()));
::foreach($v->begin(), $v->end(), MyPrint->new());

print 'remove_if($v->begin(), $v->end(), MyMatch->new(what => "^fi"));', "\n";
remove_if($v->begin(), $v->end(), MyMatch->new(what => '^fi'));
::foreach($v->begin(), $v->end(), MyPrint->new());

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
{
	package MyMatch;
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
		return ($arg->data() =~ /@{[ $self->what() ]}/i) ? $arg : 0;
	}
}
