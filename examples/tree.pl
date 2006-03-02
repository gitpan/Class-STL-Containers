#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::Containers;

print ">>>$0>>>:\n";
my $l1 = Class::STL::Containers::List->new();
$l1->push_back($l1->factory(data => 'first'));
$l1->push_back($l1->factory(data => 'second'));
$l1->push_back($l1->factory(data => 'third'));
$l1->push_back($l1->factory(data => 'fourth'));
$l1->push_back($l1->factory(data => 'fifth'));

my $l2 = Class::STL::Containers::List->new();
$l2->push_back($l2->factory(data => 'red'));
$l2->push_back($l2->factory(data => 'blue'));
$l2->push_back($l2->factory(data => 'yellow'));
$l2->push_back($l2->factory(data => 'pink'));
$l2->push_back($l2->factory(data => 'white'));

my $t1 = Class::STL::Containers::Tree->new($l1);
my $t2 = Class::STL::Containers::Tree->new($l2);

my $tree = Class::STL::Containers::Tree->new();
$tree->push_back($tree->factory($t1));
$tree->push_back($tree->factory($t2));
$tree->foreach(MyPrint->new('DATA:'));

if (my $f = $tree->find_if(MyFind->new("pink"))) {
	print "FOUND:", $f->data(), "\n";
} else {
	print "'pink' NOT FOUND", "\n";
}

$tree->remove_if($tree->matches('i'));
print "\$tree->remove_if(\$tree->matches('i'));\n";
$tree->foreach(MyPrint->new('DATA:'));
if (my $f = $tree->find_if(MyFind->new("pink"))) {
	print "FOUND:", $f->data(), "\n";
} else {
	print "'pink' NOT FOUND", "\n";
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
