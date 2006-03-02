#!/usr/bin/perl
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::Utilities.pm
#  Created	: 22 February 2006
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
use attributes qw(get reftype);
use warnings;
use vars qw($VERSION $BUILD);
use lib './lib';
$VERSION = '0.01';
$BUILD = 'Wednesday February 22 15:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities;
	use vars qw($AUTOLOAD);
	sub AUTOLOAD
	{
		my $self = shift;
		(my $func = $AUTOLOAD) =~ s/.*:://;
		return Class::STL::Utilities::EqualTo->new(@_) if ($func eq 'equal_to');
		return Class::STL::Utilities::NotEqualTo->new(@_) if ($func eq 'not_equal_to');
		return Class::STL::Utilities::Greater->new(@_) if ($func eq 'greater');
		return Class::STL::Utilities::GreaterEqual->new(@_) if ($func eq 'greater_equal');
		return Class::STL::Utilities::Less->new(@_) if ($func eq 'less');
		return Class::STL::Utilities::LessEqual->new(@_) if ($func eq 'less_equal');
		return Class::STL::Utilities::Compare->new(@_) if ($func eq 'compare');
		return Class::STL::Utilities::Matches->new(@_) if ($func eq 'matches');
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::UnaryFunction;
	sub BEGIN
	{
		our $this = __PACKAGE__;
		our @attr = qw( arg );
		eval ("sub attr { my \$self = shift; return (qw(@{[ join(' ', @attr) ]})); } ");
		foreach (@attr) {
			eval (" sub $_ { my \$self = shift; \$self->{$this}->{@{[ uc($_) ]}} = shift if (\@_);
					return \$self->{$this}->{@{[ uc($_) ]}}; } ");
		}
	}
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->arg(shift);
		return $self;
	}
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return 0; 
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::BinaryFunction;
	sub BEGIN
	{
		our $this = __PACKAGE__;
		our @attr = qw( arg1 arg2 );
		eval ("sub attr { my \$self = shift; return (qw(@{[ join(' ', @attr) ]})); } ");
		foreach (@attr) {
			eval (" sub $_ { my \$self = shift; \$self->{$this}->{@{[ uc($_) ]}} = shift if (\@_);
					return \$self->{$this}->{@{[ uc($_) ]}}; } ");
		}
	}
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->arg1(shift);
		$self->arg2(shift);
		return $self;
	}
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return 0; 
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::EqualTo;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->eq($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::NotEqualTo;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->ne($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Greater;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->gt($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::GreaterEqual;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->ge($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Less;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->lt($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::LessEqual;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->le($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Compare;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->cmp($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Matches;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do # (element) -- should override to provide condition.
	{
		my $self = shift;
		my $elem = shift;
		return $elem->match($self->arg());
	}
}
# ----------------------------------------------------------------------------------------------------
1;
