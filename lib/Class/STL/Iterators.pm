#!/usr/bin/perl
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::Iterators.pm
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
package Class::STL::Iterators;
require 5.005_62;
use strict;
use warnings;
use vars qw( $VERSION $BUILD @EXPORT );
use Exporter;
@EXPORT = qw( iterator reverse_iterator forward_iterator );
use lib './lib';
use Class::STL::DataMembers;
$VERSION = '0.01';
$BUILD = 'Wednesday February 28 21:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Iterators;
	use vars qw( $AUTOLOAD );
	sub AUTOLOAD
	{
		(my $func = $AUTOLOAD) =~ s/.*:://;
		return Class::STL::Iterators::BiDirectional->new(@_) if ($func eq 'iterator');
		return Class::STL::Iterators::Forward->new(@_) if ($func eq 'forward_iterator');
		return Class::STL::Iterators::Reverse->new(@_) if ($func eq 'reverse_iterator');
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Iterators::Abstract;
	use base qw(Class::STL::Element); 
	use overload '++' => '_incr', '--' => '_decr', '=' => 'clone', 'bool' => '_bool',
		'==' => 'eq', '!=' => 'ne', '>' => 'gt', '<' => 'lt', '>=' => 'ge', '<=' => 'le', '<=>' => 'cmp';
	sub BEGIN 
	{ 
		Class::STL::DataMembers->new(
			qw( p_element p_container ),
			Class::STL::DataMembers::Attributes->new(name => 'arr_idx', default => -1),
			Class::STL::DataMembers::Attributes->new(name => 'data_type', default => 'array'),
		);
	}
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		my @params;
		foreach (@_)
		{
			if (ref eq 'ARRAY')
			{
				CORE::push(@params, $_);
			}
			elsif (ref && $_->isa(__PACKAGE__)) # copy ctor
			{
				CORE::push(@params, 'arr_idx', $_->arr_idx(), 'data', $_->data(),
					'p_container' => $_->p_container());
			}
			else
			{
				CORE::push(@params, $_);
			}
		}
		$self = $class->SUPER::new(@params); #, data_type => 'array');
		bless($self, $class);
		$self->members_init(@params);
		$self->set($self->arr_idx()); # always set p_element via set();
		return $self;
	}
	sub set
	{
		my $self = shift;
		my $idx = shift;
		$idx = $self->p_container()->size()-1 if ($idx >= $self->p_container()->size());
		$self->arr_idx($idx);
		return if ($idx == -1);
		$self->p_element(${$self->data()}[$idx]);
	}
	sub jump # (element)
	{
		my $self = shift;
		my $elem = shift;
		foreach my $i (0..$#{$self->data()})
		{
			next unless ($elem == ${$self->data()}[$i]);
			$self->set($i);
			return $self; # iterator
		}
	}
	sub at_end # (void)
	{
		my $self = shift;
		return $self->arr_idx == -1 ? 1 : 0;
	}
	sub at_start # (void)
	{
		my $self = shift;
		return $self->arr_idx == -1 ? 1 : 0;
	}
	sub eq # (element)
	{
		my $self = shift;
		my $other = shift;
		return !$self->at_end() && !$other->at_end()
			&& $self->arr_idx() == $other->arr_idx()
			&& $self->p_element() == $other->p_element();
	}
	sub ne # (element)
	{
		my $self = shift;
		return $self->eq(shift) ? 0 : 1;
	}
	sub gt # (element)
	{
		my $self = shift;
		my $other = shift;
		return !$self->at_end() && !$other->at_end()
			&& $self->arr_idx() > $other->arr_idx();
	}
	sub ge # (element)
	{
		my $self = shift;
		my $other = shift;
		return !$self->at_end() && !$other->at_end()
			&& $self->arr_idx() >= $other->arr_idx();
	}
	sub lt # (element)
	{
		my $self = shift;
		my $other = shift;
		return !$self->at_end() && !$other->at_end()
			&& $self->arr_idx() < $other->arr_idx();
	}
	sub le # (element)
	{
		my $self = shift;
		my $other = shift;
		return !$self->at_end() && !$other->at_end()
			&& $self->arr_idx() <= $other->arr_idx();
	}
	sub cmp # (element)
	{
		my $self = shift;
		my $other = shift;
		return $self->eq($other) ? 0 : $self->lt($other) ? -1 : 1;
	}
	sub _incr
	{
		my $self = shift;
		return $self->next();
	}
	sub _decr
	{
		my $self = shift;
		return $self->prev();
	}
	sub clone
	{
		my $self = shift;
		return $self->new($self);
	}
	sub _bool
	{
		my $self = shift;
		return $self;
#>		return $self->at_end();
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Iterators::BiDirectional;
	use base qw(Class::STL::Iterators::Abstract); 
	sub first # (void)
	{
		my $self = shift;
		(!@{$self->data()})
			? $self->arr_idx(-1)
			: $self->set(0);
		return $self; # iterator
	}
	sub last # (void)
	{
		my $self = shift;
		(!@{$self->data()})
			? $self->arr_idx(-1)
			: $self->set($#{$self->data()});
		return $self; # iterator
	}
	sub prev # (void)
	{
		my $self = shift;
		(!@{$self->data()} || $self->arr_idx() == 0)
			? $self->arr_idx(-1)
			: $self->set($self->arr_idx() -1);
		return $self; # iterator
	}
	sub next # (void)
	{
		my $self = shift;
		(!@{$self->data()} || $self->arr_idx()+1 >= @{$self->data()})
			? $self->arr_idx(-1)
			: $self->set($self->arr_idx() +1);
		return $self; # iterator
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Iterator;
	use base qw(Class::STL::Iterators::BiDirectional); 
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Iterators::Forward;
	use base qw(Class::STL::Iterators::BiDirectional); 
	sub BEGIN { Class::STL::Members::Disable->new( qw ( prev last ) ); }
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Iterators::Reverse;
	use base qw(Class::STL::Iterators::BiDirectional); 
	sub last # (void)
	{
		my $self = shift;
		return $self->SUPER::first(); # iterator
	}
	sub first # (void)
	{
		my $self = shift;
		return $self->SUPER::last(); # iterator
	}
	sub next # (void)
	{
		my $self = shift;
		return $self->SUPER::prev(); # iterator
	}
	sub prev # (void)
	{
		my $self = shift;
		return $self->SUPER::next(); # iterator
	}
}
# ----------------------------------------------------------------------------------------------------
1;
