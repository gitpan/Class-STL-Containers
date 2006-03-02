#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>>\n";
my $p = Class::STL::Containers::PriorityQueue->new();
$p->push($p->factory(priority => 10, data => 'ten'));
$p->push($p->factory(priority => 2, data => 'two'));
$p->push($p->factory(priority => 12, data => 'twelve'));
$p->push($p->factory(priority => 3, data => 'three'));
$p->push($p->factory(priority => 11, data => 'eleven'));
$p->push($p->factory(priority => 1, data => 'one'));
$p->push($p->factory(priority => 1, data => 'one-2'));
$p->push($p->factory(priority => 12, data => 'twelve-2'));
$p->push($p->factory(priority => 20, data => 'twenty'), $p->factory(priority => 0, data => 'zero'));
print "\$p->size()=", $p->size(), "\n";
$p->top()->print(MyPrint->new('$p->top:'));
$p->foreach(MyPrint->new('DATA:'));
print '$p->top()->priority(7);', "\n";
print '$p->refresh();', "\n";
$p->top()->priority(7);
$p->refresh();
$p->foreach(MyPrint->new('DATA:'));
$p->top()->print(MyPrint->new('$p->top:'));
print '$p->pop();'. "\n";
$p->pop();
$p->top()->print(MyPrint->new('$p->top:'));

# ----------------------------------------------------------------------------------------------------
{
	package MyPrint;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		print $self->arg(), $elem->data(), '[', $elem->priority(), ']', "\n";
	}
}
# ----------------------------------------------------------------------------------------------------
