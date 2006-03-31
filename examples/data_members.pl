#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Class::STL::DataMembers;

{
	package MyPack;
	sub BEGIN 
	{ 
		Class::STL::DataMembers->new(
			qw(msg_text msg_type),
			Class::STL::DataMembers::Attributes->new(
				name => 'on', validate => '^(input|output)$', default => 'input'),
			Class::STL::DataMembers::Attributes->new(
				name => 'display_target', default => 'STDERR'),
			Class::STL::DataMembers::Attributes->new(
				name => 'count', validate => '^\d+$', default => '100'),
			Class::STL::DataMembers::Attributes->new(
				name => 'comment', validate => '^\w+$', default => 'hello'),
		); 
	}
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
}

print ">>>$0>>>>:\n";

my $p = MyPack->new();
print "\$p->member_print():", $p->member_print(), "\n";

print "\$p->count(25);\n";
$p->count(25);
print "\$p->member_print():", $p->member_print(), "\n";

print "\$p->comment(\$p->comment() . 'world');\n";
$p->comment($p->comment() . 'world');
print "\$p->member_print(\"\\n\"):\n", $p->member_print("\n"), "\n";
