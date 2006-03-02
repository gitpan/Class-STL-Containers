#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>:\n";
my $d1 = Class::STL::Containers::Deque->new();
$d1->push_back($d1->factory(data => 'first'));
$d1->push_back($d1->factory(data => 'second'));
$d1->push_back($d1->factory(data => 'third'));
$d1->push_back($d1->factory(data => 'fourth'));
$d1->push_back($d1->factory(data => 'fifth'));
$d1->foreach(MyPrint->new('DEQUE-1:'));

my $d2 = Class::STL::Containers::Deque->new($d1);
$d2->foreach(MyPrint->new('DEQUE-2:'));

print "Deques d1 and d2 are ", ($d1->eq($d2) ? " equal" : " not equal"). "\n";
$d2->push($d2->factory(data => 'sixth'));
print '$d2->push($d2->factory(data => "sixth"));', "\n";
print "Deques d1 and d2 are ", ($d1->eq($d2) ? " equal" : " not equal"). "\n";


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
