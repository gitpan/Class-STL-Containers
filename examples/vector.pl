#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>:\n";
my $v = Class::STL::Containers::Vector->new();
$v->push_back($v->factory(data => 'first'));
$v->push_back($v->factory(data => 'second'));
$v->push_back($v->factory(data => 'third'));
$v->push_back($v->factory(data => 'fourth'));
$v->push_back($v->factory(data => 'fifth'));

my $e = $v->at(0);
$e->print(MyPrint->new('Element-0:'));
$e = $v->at($v->size()-1);
$e->print(MyPrint->new('Element-last:'));
$e = $v->at(2);
$e->print(MyPrint->new('Element-2:'));
$v->pop_back();
$v->push_back($v->factory(data => 'sixth'));
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
