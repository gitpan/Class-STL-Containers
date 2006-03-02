#!/usr/bin/perl
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::Element.pm
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
$BUILD = 'Wednesday February 28 21:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Element;
	use UNIVERSAL qw(isa can);
	sub BEGIN
	{
		our $this = __PACKAGE__;
		our @attr = qw( data data_type );
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
		my @params;
		foreach (@_)
		{
			if (ref eq 'ARRAY')
			{
				CORE::push(@params, $_);
			}
			elsif (ref && $_->isa(__PACKAGE__)) # copy ctor
			{
				CORE::push(@params, 'data', $_->data(), 'data_type', $_->data_type());
			}
			elsif (ref)
			{
				CORE::push(@params, 'data', $_);
			}
			else
			{
				CORE::push(@params, $_);
			}
		}
		my %p = @params;
		$self->data($p{'data'});
		$self->data_type($p{'data_type'} || 'string');
		return $self;
	}
	sub eq # (element)
	{
		my $self = shift;
		my $other = shift;
		return ref($self->data()) && $self->data()->can('eq')
			? $self->data()->eq($other)
			: $self->data_type() eq 'string'
				? $self->data() eq $other->data()
				: $self->data() == $other->data();
	}
	sub ne # (element)
	{
		my $self = shift;
		return !$self->eq(shift);
	}
	sub gt # (element)
	{
		my $self = shift;
		my $other = shift;
		return ref($self->data()) && $self->data()->can('gt')
			? $self->data()->gt($other)
			: $self->data_type() eq 'string'
				? $self->data() gt $other->data()
				: $self->data() > $other->data();
	}
	sub lt # (element)
	{
		my $self = shift;
		my $other = shift;
		return ref($self->data()) && $self->data()->can('lt')
			? $self->data()->lt($other)
			: $self->data_type() eq 'string'
				? $self->data() lt $other->data()
				: $self->data() < $other->data();
	}
	sub ge # (element)
	{
		my $self = shift;
		my $other = shift;
		return ref($self->data()) && $self->data()->can('ge')
			? $self->data()->ge($other)
			: $self->data_type() eq 'string'
				? $self->data() ge $other->data()
				: $self->data() >= $other->data();
	}
	sub le # (element)
	{
		my $self = shift;
		my $other = shift;
		return ref($self->data()) && $self->data()->can('le')
			? $self->data()->le($other)
			: $self->data_type() eq 'string'
				? $self->data() le $other->data()
				: $self->data() <= $other->data();
	}
	sub cmp # (element)
	{
		my $self = shift;
		my $other = shift;
		return $self->eq($other) ? 0 : $self->lt($other) ? -1 : 1;
	}
	sub match # (element)
	{
		my $self = shift;
		my $regex = shift;
		return $self->data() =~ /@{[ $regex ]}/;
	}
	sub print # (UnaryFuncation)
	{
		my $self = shift;
		my $util = shift;
		$util->do($self);
	}
}
# ----------------------------------------------------------------------------------------------------
1;
