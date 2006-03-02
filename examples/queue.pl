#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>:\n";
my $v = Class::STL::Containers::Queue->new();
$v->push($v->factory(data => 'first'));
$v->push($v->factory(data => 'second'));
$v->push($v->factory(data => 'third'));
$v->push($v->factory(data => 'fourth'));
$v->push($v->factory(data => 'fifth'));

$v->foreach(MyPrint->new('DATA:'));
$v->back()->print(MyPrint->new('Back:'));
$v->front()->print(MyPrint->new('Front:'));
print '$v->pop();', "\n";
print '$v->push($v->factory(data => "sixth"));', "\n";
$v->pop();
$v->push($v->factory(data => 'sixth'));
$v->back()->print(MyPrint->new('Back:'));
$v->front()->print(MyPrint->new('Front:'));

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
