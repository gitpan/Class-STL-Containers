#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>:\n";
my $v = Class::STL::Containers::List->new();
$v->push_back($v->factory(data => 'first'));
$v->push_back($v->factory(data => 'second'));
$v->push_back($v->factory(data => 'third'));
$v->push_back($v->factory(data => 'fourth'));
$v->push_back($v->factory(data => 'fifth'));
$v->foreach(MyPrint->new("DATA:"));
print "Element 'second' was ", $v->find_if(MyFind->new("second")) ? 'found' : 'not found', "\n";

# ----------------------------------------------------------------------------------------------------
{
	package MyFind;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		return $elem->data() eq $self->arg() ? $elem : 0;
	}
}
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
