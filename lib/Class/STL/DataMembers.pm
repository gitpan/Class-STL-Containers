#!/usr/bin/perl
# vim:ts=4 sw=4
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::DataMembers.pm
#  Created	: 24 March 2006
#  Author	: Mario Gaffiero (gaffie)
#
# Copyright 2006 Mario Gaffiero.
# 
# This file is part of Class::STL::Containers(TM).
# 
# Class::STL::Containers is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# Class::STL::Containers is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Class::STL::Containers; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# ----------------------------------------------------------------------------------------------------
# Modification History
# When          Version     Who     What
# ----------------------------------------------------------------------------------------------------
# TO DO:
# ----------------------------------------------------------------------------------------------------
require 5.005_62;
use strict;
use warnings;
use vars qw($VERSION $BUILD);
use lib './lib';
$VERSION = '0.01';
$BUILD = 'Thursday March 23 15:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::DataMembers;
	use UNIVERSAL qw(isa can);
	use Carp qw(cluck);
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->_caller((caller())[0]);
		$self->_debug(0);
		$self->_members(@_);
		return $self;
	}
	sub new_debug
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->_caller((caller())[0]);
		$self->_debug(1);
		$self->_members(@_);
		return $self;
	}
	# ----------------------------------------------------------------------------------------------------
	# PRIVATE
	# ----------------------------------------------------------------------------------------------------
	sub DESTROY
	{
		my $self = shift;
		my @code;
		push(@code, map($self->_public_member_func($_), values(%{$self->_members()})));
		push(@code, $self->_init_func());
		push(@code, $self->_print_func());
		push(@code, $self->_members_func());
#>		push(@code, $self->_new_func()) unless (???);
		print STDERR "# @{[ $self->_caller() ]} Data Members:", join('|', keys( %{$self->_members()} )), "\n"
			if ($self->_debug());
		print STDERR join("", @code), "\n" if ($self->_debug());
		eval(join("", @code));
		cluck "**Error in eval for @{[ $self->_caller() ]} DataMembers functions creation:\n$@" if ($@);
	}
	sub _debug
	{
		my $self = shift;
		$self->{__PACKAGE__}->{DEBUG} = shift if (@_);
		return $self->{__PACKAGE__}->{DEBUG};
	}
	sub _caller
	{
		my $self = shift;
		$self->{__PACKAGE__}->{CALLER} = shift if (@_);
		return $self->{__PACKAGE__}->{CALLER};
	}
	sub _caller_str
	{
		my $self = shift;
		my $str = $self->_caller();
		$str =~ s/[:]+/_/g;
		return $str;
	}
	sub _members
	{
		my $self = shift;
		if (@_)
		{
			foreach my $member (@_)
			{
				ref($member) && $member->isa('Class::STL::DataMembers::Attributes')
					?  $self->{MEMBERS}->{$member->name()} = $member
					:  $self->{MEMBERS}->{$member} = $member;
			}
		}
		return $self->{MEMBERS};
	}
	sub _public_member_func
	{
		my $self = shift;
		my $member = shift;
		my $tab = ' ' x 4;
		my $member_name = ref($member) && $member->isa('Class::STL::DataMembers::Attributes') 
			? $member->name() : $member;
		my $code = "sub @{[ $self->_caller() ]}\::$member_name {\n${tab}my \$self = shift;\n";

		if (ref($member) && $member->isa('Class::STL::DataMembers::Attributes') && defined($member->validate()))
		{
			$code .= $member->accessor_func_code();
		}
		else
		{
			$code .= "${tab}\$self->{@{[ $self->_caller_str() ]}}->{@{[ uc($member_name) ]}} = shift if (\@_);\n";
		}
		$code .= "${tab}return \$self->{@{[ $self->_caller_str() ]}}->{@{[ uc($member_name) ]}};\n";
		$code .= "}\n";
		return $code;
	}
	sub _init_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub @{[ $self->_caller() ]}\::members_init {\n";
		$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}my \%p = \@_;\n";
		$code .= "${tab}@{[ join(\"\n    \", map($self->_member_init_func($_), values( %{$self->_members()} ))) ]}\n";
		$code .= "}\n";
		return $code;
	}
	sub _print_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub @{[ $self->_caller() ]}\::member_print {\n";
		$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}my \$delim = shift || '|';\n";
		$code .= "${tab}return join(\"\$delim\",\n${tab}${tab}";
		$code .= 
			join(qq/,\n$tab$tab/, 
				map
				(
					qq/"$_=\@{[ defined(\$self->$_()) ? \$self->$_() : 'NULL' ]}"/, 
					sort(map(ref($_) ? $_->name() : $_, values( %{$self->_members()} )))
				)
			);
		$code .= "\n${tab});\n";
		$code .= "}\n";
		return $code;
	}
	sub _member_init_func
	{
		my $self = shift;
		my $member = shift;
		my $member_name = ref($member) && $member->isa('Class::STL::DataMembers::Attributes') 
			? $member->name() : $member;
		return ref($member) && $member->isa('Class::STL::DataMembers::Attributes')
			? $member->init_func_code()
			: "\$self->$member_name(\$p{'$member_name'});";
	}
	sub _members_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub @{[ $self->_caller() ]}\::members {\n";
    	$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}return [ qw( @{[ join(' ', sort keys(%{$self->_members()})) ]} ) ];\n";
		$code .= "}\n";
		return $code;
	}
	sub _new_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub @{[ $self->_caller() ]}\::members {\n";
    	$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}my \$class = ref(\$self) || \$self;\n";
		$code .= "${tab}\$self = \$class->SUPER::new(\@_);\n";
		$code .= "${tab}bless(\$self, \$class);\n";
		$code .= "${tab}\$self->members_init(\@_);\n";
		$code .= "${tab}return \$self;\n";
		$code .= "}\n";
		return $code;
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::DataMembers::Attributes;
	sub BEGIN { Class::STL::DataMembers->new(qw( name default validate _caller )); }
	use Carp qw(cluck);
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->members_init(_caller => (caller())[0], @_);
		return $self;
	}
	sub init_func_code
	{
		my $self = shift;
		return "\$self->@{[ $self->name() ]}("
			. (defined($self->default())
				? "exists(\$p{'@{[ $self->name() ]}'}) ? \$p{'@{[ $self->name() ]}'} : '@{[ $self->default() ]}'"
				: "\$p{'@{[ $self->name() ]}'}")
			. ");";
	}
	sub accessor_func_code
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "${tab}if (\@_) {\n";
		$code .= "${tab}${tab}die \"**Field '@{[ $self->name() ]}' value '\$_[0]' failed validation ('\" . '@{[ $self->validate() ]}' . \"')\"\n";
		$code .= "${tab}${tab}${tab}unless (\$_[0] =~ /@{[ $self->validate() ]}/);\n";
		$code .= "${tab}${tab}\$self->{@{[ $self->_caller_str() ]}}->{@{[ uc($self->name()) ]}} = shift;\n";
		$code .= "${tab}}\n";
		return $code;
	}
	sub _caller_str
	{
		my $self = shift;
		my $str = $self->_caller();
		$str =~ s/[:]+/_/g;
		return $str;
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Members::Disable;
	sub BEGIN { Class::STL::DataMembers->new(qw( _caller )); }
	use Carp qw(cluck);
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->members_init(_caller => (caller())[0]);
		my $tab = ' ' x 4;
		my $code;
		foreach my $m (@_)
		{
			$code .= "sub @{[ $self->_caller() ]}\::$m {\n";
			$code .= "${tab}use Carp qw(confess);\n";
			$code .= "${tab}confess \"Function '$m' not available for @{[ $self->_caller() ]}!\";\n";
			$code .= "}\n";
		}
		eval($code);
		cluck "**Error in eval for @{[ $self->_caller() ]} Members::Disable functions creation:\n$@" if ($@);
		return $self;
	}
}
# ----------------------------------------------------------------------------------------------------
1;
