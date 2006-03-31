#!/usr/bin/perl
# vim:ts=4 sw=4
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
# 14/03/2006	0.02		mg		Fixed Class::STL::Element->new() function.
# ----------------------------------------------------------------------------------------------------
# TO DO:
# ----------------------------------------------------------------------------------------------------
require 5.005_62;
use strict;
use warnings;
use vars qw($VERSION $BUILD);
use lib './lib';
use Class::STL::DataMembers;
$VERSION = '0.01';
$BUILD = 'Monday March 27 21:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Element;
	use UNIVERSAL qw(isa can);
	sub BEGIN { Class::STL::DataMembers->new(qw( data data_type )); }
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->data_type('string');
		while (@_)
		{
			my $p = shift;
			if (!ref($p) && $p eq 'data') {
				$self->data(shift);
			}
			elsif (!ref($p) && $p eq 'data_type') {
				$self->data_type(shift);
			}
			elsif (ref($p) eq 'ARRAY') {
				$self->data($p);
			}
			elsif (ref($p) && $p->isa(__PACKAGE__)) # copy ctor
			{
				$self->data($p->data());
				$self->data_type($p->data_type());
			}
		}
		return $self;
	}
	sub clone
	{
		my $self = shift;
		return $self->new($self);
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
#<	sub match # (element)
#<	{
#<		my $self = shift;
#<		my $regex = shift;
#<		return $self->data() =~ /@{[ $regex ]}/ ? $self : 0;
#<	}
#<	sub print # (UnaryFunction)
#<	{
#<		my $self = shift;
#<		my $util = shift;
#<		$util->do($self);
#<	}
}
# ----------------------------------------------------------------------------------------------------
1;
