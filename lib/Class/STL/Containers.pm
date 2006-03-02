#!/usr/bin/perl
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::Containers.pm
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
	package Class::STL::Containers::Abstract;
	use base qw(Class::STL::Element); # container is also an element
	use base qw(Class::STL::Algorithms);
	use Class::STL::Iterators;
	use UNIVERSAL qw(isa can);
	sub BEGIN
	{
		our $this = __PACKAGE__;
		our @attr = qw( name iterator element_type );
		eval ("sub attr { my \$self = shift; return (\$self->SUPER::attr, qw(@{[ join(' ', @attr) ]})); } ");
		foreach (@attr) {
			eval (" sub $_ : method { my \$self = shift; \$self->{$this}->{@{[ uc($_) ]}} = shift if (\@_);
					return \$self->{$this}->{@{[ uc($_) ]}}; } ");
		}
	}
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		my @copy_containers;
		my @copy_elements;
		my @copy_iterators;
		my @params;
		foreach (@_)
		{
			if (ref && $_->isa(__PACKAGE__)) # copy ctor
			{
				CORE::push(@copy_containers, $_);
				CORE::push(@params, 'element_type', $_->element_type);
			}
			elsif (ref && $_->isa('Class::STL::Iterator')) # what to do with these?
			{
				# Need to copy elements from/to iterator(s)
				CORE::push(@copy_iterators, $_);
			}
			elsif (ref && $_->isa('Class::STL::Element'))
			{
				CORE::push(@copy_elements, $_);
			}
			else
			{
				CORE::push(@params, $_);
			}
		}
		$self = $class->SUPER::new(@params, data_type => 'array');
		bless($self, $class);
		my %p = @params;
		$self->name($p{'name'}) if (defined($p{'name'}));
		$self->element_type($p{'element_type'} || 'Class::STL::Element');
		die "element_type (@{[ $self->element_type() ]}) must be derived from Class::STL::Element!"
			unless (UNIVERSAL::isa($self->element_type(), 'Class::STL::Element'));
		$self->data([]); # Array data of (base) type Class::STL::Element
		# NOTE: iterator->data() MUST be reset whenever $self->data is set.
		$self->iterator(Class::STL::Iterator->new(data => $self->data()));
		foreach (@copy_containers) {
			$self->push(@{$_->data()});
		}
		foreach (@copy_elements) {
			$self->push($_);
		}
		return $self;
	}
	sub factory # (@params) -- construct an element object and return it;
	{
		my $self = shift;
		return eval("@{[ $self->element_type() ]}->new(\@_);");
	}
	sub swap # (element, element)
	{
		my $self = shift;
		my $elem1_idx = $self->iterator()->jump(shift)->arr_idx();
		my $elem2_idx = $self->iterator()->jump(shift)->arr_idx();
		my $tmp = ${$self->data()}[$elem1_idx];
		${$self->data()}[$elem1_idx] = ${$self->data()}[$elem2_idx];
		${$self->data()}[$elem2_idx] = $tmp;
		# void return
	}
	sub erase # (element [, ... ])
	{
		my $self = shift;
		my $idx;
		foreach (grep(ref && $_->isa('Class::STL::Element'), @_)) {
			next if (($idx = $self->iterator()->jump($_)->arr_idx()) == -1);
			CORE::splice(@{$self->data()}, $idx, 1);
		}
		# void return
	}
	sub push # (element)
	{
		my $self = shift;
		my $curr_sz = $self->size();
		CORE::push(@{$self->data()}, grep(ref && $_->isa('Class::STL::Element'), @_));
		$self->end();
		return $self->size() - $curr_sz; # number of new elements inserted.
	}
	sub pop # (void)
	{
		my $self = shift;
		my $back = CORE::pop(@{$self->data()});
		$self->end();
		# void return
	}
	sub top # (void) -- ???
	{
		my $self = shift;
		return $self->end()->p_element(); # element ref
	}
	sub clear # (void)
	{
		my $self = shift;
		$self->data([]);
		$self->iterator()->data($self->data());
		# void return
	}
#TODO	sub insert # (iterator, element [, ...]) -- Insert element(s) before iterator position
#TODO	sub insert # (iterator, iter_start, iter_end) -- copy iter_start..iter_end elements to position iterator
	sub insert # (element [, ...]) -- Insert element(s) before current iterator->arr_idx()
	{
		my $self = shift;
		if (!$self->size())
		{
			my $num_inserted = $self->push(@_);
			$self->iterator()->set($self->size() - int($num_inserted));
		}
		else
		{
			CORE::splice(@{$self->data()}, $self->iterator()->arr_idx(), 0, 
				grep(ref && $_->isa('Class::STL::Element'), @_));
			$self->iterator()->set($self->iterator()->arr_idx());
		}
		return $self->iterator(); # iterator -- points to first new element inserted
	}
	sub begin # (void)
	{
		my $self = shift;
		return $self->iterator()->first(); # iterator
	}
	sub end # (void)
	{
		# WARNING: end() points to last element unlike STL-end() which points to after last element!!
		# See examples/iterator.pl for correct iterator traversal example.
		my $self = shift;
		return $self->iterator()->last(); # iterator
	}
	sub rbegin # (void)
	{
		my $self = shift;
		return $self->iterator()->last(); # iterator
#TODO	return $self->reverse_iterator()->last(); # reverse_iterator
	}
	sub rend # (void)
	{
		my $self = shift;
		return $self->iterator()->first(); # iterator
#TODO	return $self->reverse_iterator()->first(); # reverse_iterator
	}
	sub size # (void)
	{
		my $self = shift;
		return int(@{$self->data()});
	}
	sub empty # return bool
	{
		my $self = shift;
		return $self->size() ? 0 : 1; # 1==true; 0==false
	}
	sub to_array # (void) -- maybe replace with foreach()
	{
		my $self = shift;
		my $level = shift || undef;

		return (map($_->data(), @{$self->data()})) # array of data
			unless (defined($level));

		my @nodes;
		foreach (@{$self->data()}) { # traverse tree...
			($_->isa('Class::STL::Containers::Abstract'))
				? CORE::push(@nodes, $_->to_array($level+1)) 
				: CORE::push(@nodes, $_->data());
		}
		return @nodes;
	}
	sub eq # (vector)
	{
		my $self = shift;
		my $other = shift;
		return 0 unless $self->size() == $other->size();
		my $i1=$self->iterator()->first(); 
		my $i2=$other->iterator()->first(); 
		while (!$i1->at_end() && !$i2->at_end())
		{
			return 0 unless ($i1->p_element()->eq($i2->p_element()));
			$i1->next();
			$i2->next();
		}
		return 1; # containers are equal
	}
	sub ne 
	{
		my $self = shift;
		return !$self->eq(shift);
	}
	sub gt
	{
		my $self = shift;
		my $other = shift;
		return 0 unless $self->size() == $other->size();
		foreach my $i (0..$self->size()-1) {
			return 0 unless (${$self->data()}[$i]->gt(${$other->data()}[$i]));
		}
		return 1; # this container gt other
	}
	sub lt
	{
		my $self = shift;
		my $other = shift;
		return 0 unless $self->size() == $other->size();
		foreach my $i (0..$self->size()-1) {
			return 0 unless (${$self->data()}[$i]->lt(${$other->data()}[$i]));
		}
		return 1; # this containers lt other
	}
	sub ge
	{
		my $self = shift;
		my $other = shift;
		return 0 unless $self->size() == $other->size();
		foreach my $i (0..$self->size()-1) {
			return 0 unless (${$self->data()}[$i]->ge(${$other->data()}[$i]));
		}
		return 1; # this containers ge other
	}
	sub le
	{
		my $self = shift;
		my $other = shift;
		return 0 unless $self->size() == $other->size();
		foreach my $i (0..$self->size()-1) {
			return 0 unless (${$self->data()}[$i]->le(${$other->data()}[$i]));
		}
		return 1; # this containers le other
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Vector;
	use base qw(Class::STL::Containers::Abstract); # vector is also an element
	use UNIVERSAL qw(isa can);

	sub push_back # (element [, ...])
	{
		my $self = shift;
		return $self->push(@_); # number of new elements inserted.
	}
	sub pop_back # (void)
	{
		my $self = shift;
		$self->pop();
		# void return
	}
	sub back # (void)
	{
		my $self = shift;
		return $self->end()->p_element(); # element ref
	}
	sub front # (void)
	{
		my $self = shift;
		return $self->begin()->p_element(); # element ref
	}
	sub at # (idx)
	{
		my $self = shift;
		my $idx = shift;
		$idx = $self->iterator()->arr_idx() unless (defined($idx));
		return ${$self->data()}[$idx]; # element ref
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Deque;
	use base qw(Class::STL::Containers::Vector);
	use UNIVERSAL qw(isa can);

	sub push_front # (element [, ...])
	{
		my $self = shift;
		my $curr_sz = $self->size();
		unshift(@{$self->data()}, grep(ref && $_->isa("Class::STL::Element"), @_));
		$self->begin();
		return $self->size() - $curr_sz; # number of new elements inserted.
	}
	sub pop_front # (void)
	{
		my $self = shift;
		my $front = shift(@{$self->data()});
		$self->begin();
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Queue;
	use base qw(Class::STL::Containers::Abstract);
	use UNIVERSAL qw(isa can);

	sub push_back
	{
		my $self = shift;
		die "Function 'push_back' not available for queue.";
	}
	sub pop_back 
	{
		my $self = shift;
		die "Function 'push_back' not available for queue.";
	}
	sub back # (void)
	{
		my $self = shift;
		return $self->top();
	}
	sub front # (void)
	{
		my $self = shift;
		return $self->begin()->p_element(); # element ref
	}
	sub push # (element [,...]) -- push to back
	{
		my $self = shift;
		$self->SUPER::push(@_);
	}
	sub pop # (void) -- pop from front
	{
		my $self = shift;
		shift(@{$self->data()});
		$self->begin();
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Stack;
	use base qw(Class::STL::Containers::Abstract);
	use UNIVERSAL qw(isa can);

	sub push_back
	{
		my $self = shift;
		die "Function 'push_back' not available for stack.";
	}
	sub pop_back 
	{
		my $self = shift;
		die "Function 'push_back' not available for stack.";
	}
	sub front 
	{
		my $self = shift;
		die "Function 'front' not available for stack.";
	}
	sub top # (void)
	{
		my $self = shift;
		return $self->SUPER::top();
	}
	sub push # (element [,...])
	{
		my $self = shift;
		$self->SUPER::push(@_);
	}
	sub pop # (void)
	{
		my $self = shift;
		$self->SUPER::pop();
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Tree;
	use base qw(Class::STL::Containers::Deque);
	use UNIVERSAL qw(isa can);

	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_, element_type => __PACKAGE__);
		bless($self, $class);
		return $self;
	}
	sub to_array # (void)
	{
		my $self = shift;
		$self->SUPER::to_array(1);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::List;
	use base qw(Class::STL::Containers::Deque);
	use UNIVERSAL qw(isa can);

	sub at
	{
		my $self = shift;
		die "Function 'at' not available for list.";
	}
	sub reverse # (void)
	{
		my $self = shift;
		$self->data([ CORE::reverse(@{$self->data()}) ]);
		$self->iterator()->data($self->data());
	}
	sub sort # (void | cmp)
	{
		my $self = shift;
		$self->data([ CORE::sort { $a->cmp($b) } (@{$self->data()}) ]);
		$self->iterator()->data($self->data());
		# sort according to cmp 
	}
	sub splice
	{
		#TODO
	}
	sub merge
	{
		#TODO
	}
	sub remove # (element)
	{
		#TODO
	}
	sub unique # (void | predicate)
	{
		#TODO
		#Erases consecutive elements matching a true condition of the binary_pred. The first occurrence is not removed.
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Element::Priority;
	use base qw(Class::STL::Element);
	use UNIVERSAL qw(isa can);

	sub BEGIN
	{
		our $this = __PACKAGE__;
		our @attr = qw( priority );
		eval ("sub attr { my \$self = shift; return (qw(@{[ join(' ', @attr) ]})); } ");
		foreach (@attr) {
			eval (" sub $_ { my \$self = shift; \$self->{$this}->{@{[ uc($_) ]}} = shift if (\@_);
			return \$self->{$this}->{@{[ uc($_) ]}}; } ");
		}
	}
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		my %p = @_;
		$self->priority($p{'priority'} || 0);
		return $self;
	}
	sub cmp
	{
		my $self = shift;
		my $other = shift;
		return $self->eq($other) ? 0 : $self->lt($other) ? -1 : 1;
	}
	sub eq # (element)
	{
		my $self = shift;
		my $other = shift;
		return $self->priority() == $other->priority();
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
		return $self->priority() > $other->priority();
	}
	sub lt # (element)
	{
		my $self = shift;
		my $other = shift;
		return $self->priority() < $other->priority();
	}
	sub ge # (element)
	{
		my $self = shift;
		my $other = shift;
		return $self->priority() >= $other->priority();
	}
	sub le # (element)
	{
		my $self = shift;
		my $other = shift;
		return $self->priority() <= $other->priority();
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::PriorityQueue;
	use base qw(Class::STL::Containers::Vector);
	use UNIVERSAL qw(isa can);

	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_, element_type => 'Class::STL::Element::Priority');
		bless($self, $class);
		my %p = @_;
		return $self;
	}
	sub push
	{
		my $self = shift;
		while (my $d = shift)
		{
			if (!$self->size() || $d->ge($self->top()))
			{
				$self->SUPER::push($d);
				next;
			}
			for (my $i=$self->iterator()->first(); !$i->at_end(); $i->next())
			{
				if ($i->p_element()->gt($d))
				{
					$self->insert($d);
					last;
				}
			}
		}
	}
	sub pop
	{
		my $self = shift;
		$self->SUPER::pop();
	}
	sub top
	{
		my $self = shift;
		return $self->SUPER::top();
	}
	sub refresh
	{
		# If the priority values were modified then a refresh() is required to re-order the elements.
		my $self = shift;
		$self->data([ CORE::sort { $a->cmp($b) } (@{$self->data()}) ]);
		$self->iterator()->data($self->data());
		# sort according to cmp 
	}
	sub push_back
	{
		my $self = shift;
		die "Function 'push_back' not available for priority_queue.";
	}
	sub pop_back 
	{
		my $self = shift;
		die "Function 'push_back' not available for priority_queue.";
	}
	sub front 
	{
		my $self = shift;
		die "Function 'front' not available for priority_queue.";
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Set;
	use base qw(Class::STL::Containers::Abstract);
	#TODO
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::MultiSet;
	use base qw(Class::STL::Containers::Set);
	#TODO
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Map;
	use base qw(Class::STL::Containers::Abstract);
	#TODO
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::MultiMap;
	use base qw(Class::STL::Containers::Map);
	#TODO
}
# ----------------------------------------------------------------------------------------------------
1;
