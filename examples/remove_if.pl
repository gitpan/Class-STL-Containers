#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>\n";
my $v = Class::STL::Containers::List->new();
$v->push_back($v->factory(data => 'first'));
$v->push_back($v->factory(data => 'second'));
$v->push_back($v->factory(data => 'third'));
$v->push_back($v->factory(data => 'fourth'));
$v->push_back($v->factory(data => 'fifth'));

$v->foreach(MyPrint->new('DATA:'));
print '$v->remove_if($v->equal_to($v->back()));', "\n";
$v->remove_if($v->equal_to($v->back()));
$v->foreach(MyPrint->new('DATA:'));
print '$v->remove_if($v->matches(^fi));', "\n";
$v->remove_if($v->matches('^fi'));
$v->foreach(MyPrint->new('DATA:'));

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
