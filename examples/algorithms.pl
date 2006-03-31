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

print "Static Foreach with unary-function-object:\n";
::foreach($v->begin(), $v->end(), MyPrint->new());

my $v2 = list(data_type => 'MyElem');
$v2->push_back($v2->factory(data => 'red'));
$v2->push_back($v2->factory(data => 'blue'));
$v2->push_back($v2->factory(data => 'green'));
$v2->push_back($v2->factory(data => 'yellow'));
$v2->push_back($v2->factory(data => 'white'));
my $t1 = tree($v);
my $t2 = tree($v2);
my $tree = tree();
print "\$tree->size()=", $tree->size(), "\n";
$tree->push_back($tree->factory($t1));
$tree->push_back($tree->factory($t2));

print "Tree Foreach:\n";
::foreach($tree->begin(), $tree->end(), MyPrint->new());

print "Tree Find_If 'yellow':",
	find_if($tree->begin(), $tree->end(), MyFind->new(what => 'yellow'))
	? '...Found' : '...Not found!', "\n";

print "Tree Count_If(/e/i):",
	count_if($tree->begin(), $tree->end(), MyMatch->new(what => 'e')),
	"\n";

print "Tree Remove_If(/l/i):\n";
remove_if($tree->begin(), $tree->end(), MyMatch->new(what => 'l'));
::foreach($tree->begin(), $tree->end(), MyPrint->new());

print "Tree Find_If 'yellow':",
	find_if($tree->begin(), $tree->end(), MyFind->new(what => 'yellow'))
	? '...Found' : '...Not found!', "\n";

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
