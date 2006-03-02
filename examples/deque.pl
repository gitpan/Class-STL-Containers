#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>:\n";
my $d = Class::STL::Containers::Deque->new();
$d->push_back($d->factory(data => 'first'));
$d->push_back($d->factory(data => 'second'));
$d->push_back($d->factory(data => 'third'));
$d->push_back($d->factory(data => 'fourth'));
$d->push_back($d->factory(data => 'fifth'));
$d->foreach(MyPrint->new('DATA:'));
print '$d->push_front($d->factory(data => \'seventh\'));', "\n";
$d->push_front($d->factory(data => 'seventh'));
$d->foreach(MyPrint->new('DATA:'));
$d->pop_front();
print '$d->pop_front();', "\n";
$d->foreach(MyPrint->new('DATA:'));
$d->pop_back();
print '$d->pop_back();', "\n";
$d->foreach(MyPrint->new('DATA:'));
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
