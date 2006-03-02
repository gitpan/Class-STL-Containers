#!/usr/bin/perl
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::Alogorithms.pm
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
	package Class::STL::Algorithms;
	use base qw(Class::STL::Utilities);
	use UNIVERSAL qw(isa can);

	sub remove_if # (unary-function)
	{
		my $self = shift;
		my $util = shift;
		my $i = 0;
		while (1)
		{
			last if ($i >= $self->size());
			if (ref(${$self->data()}[$i]) && ${$self->data()}[$i]->isa('Class::STL::Containers::Abstract')
					? ${$self->data()}[$i]->remove_if($util) # its a tree -- recurse
					: $util->do(${$self->data()}[$i]))
			{
				CORE::splice(@{$self->data()}, $i, 1);
				next;
			}
			$i++;
		}
		$self->end();
		return;
	}
	sub find_if # (unary-function)
	{
		my $self = shift;
		my $util = shift;
		my $i = 0;
		while (1)
		{
			last if ($i >= $self->size());
			if (my $e = 
				ref(${$self->data()}[$i]) && ${$self->data()}[$i]->isa('Class::STL::Containers::Abstract')
					? ${$self->data()}[$i]->find_if($util) # its a tree -- recurse
					: $util->do(${$self->data()}[$i]))
			{
				return $e;
			}
			$i++;
		}
		$self->end();
		return;
	}
	sub foreach # (unary-function)
	{
		my $self = shift;
		my $util = shift;
		my $i = 0;
		while (1)
		{
			last if ($i >= $self->size());
			ref(${$self->data()}[$i]) && ${$self->data()}[$i]->isa('Class::STL::Containers::Abstract')
				? ${$self->data()}[$i]->foreach($util) # its a tree -- recurse
				: $util->do(${$self->data()}[$i]);
			$i++;
		}
		$self->end();
		return;
	}
}
# ----------------------------------------------------------------------------------------------------
1;
