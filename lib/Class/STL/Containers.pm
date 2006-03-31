#!/usr/bin/perl
# vim:ts=4 sw=4
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
package Class::STL::Containers;
require 5.005_62;
use strict;
use warnings;
use vars qw( $VERSION $BUILD @EXPORT );
use Exporter;
@EXPORT = qw( vector list deque queue priority_queue stack tree );
use lib './lib';
use Class::STL::DataMembers;
$VERSION = 0.05;
$BUILD = 'Friday March 31 21:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers;
	use vars qw( $AUTOLOAD );
	sub AUTOLOAD
	{
		(my $func = $AUTOLOAD) =~ s/.*:://;
		return Class::STL::Containers::Vector->new(@_) if ($func eq 'vector');
		return Class::STL::Containers::List->new(@_) if ($func eq 'list');
		return Class::STL::Containers::Deque->new(@_) if ($func eq 'deque');
		return Class::STL::Containers::Queue->new(@_) if ($func eq 'queue');
		return Class::STL::Containers::PriorityQueue->new(@_) if ($func eq 'priority_queue');
		return Class::STL::Containers::Stack->new(@_) if ($func eq 'stack');
		return Class::STL::Containers::Tree->new(@_) if ($func eq 'tree');
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Abstract;
	use base qw(Class::STL::Element); # container is also an element
	use overload '+' => 'append', '+=' => 'append', '=' => 'clone', 
		'==' => 'eq', '!=' => 'ne', '>' => 'gt', '<' => 'lt', '>=' => 'ge', '<=' => 'le', '<=>' => 'cmp';
	use Class::STL::Iterators;
	use UNIVERSAL qw(isa can);
	use Carp qw(confess);
	sub BEGIN 
	{ 
		Class::STL::DataMembers->new(
			Class::STL::DataMembers::Attributes->new(
				name => 'data_type', default => 'Class::STL::Element'),
		);
	}
	# new(named-argument-list);
	# new(container-ref); -- copy ctor
	# new(element [, ...]); -- initialise new container with element(s).
	# new(iterator-start); -- initialise new container with copy of elments from other container.
	# new(iterator-start, iterator-finish); -- initialise new container with copy of elments from other container.
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
				CORE::push(@params, 'data_type', $_->data_type());
			}
			elsif (ref && $_->isa('Class::STL::Iterators::Abstract')) 
			{
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
		$self->members_init(@params);
		confess "data_type (@{[ $self->data_type() ]}) must be derived from Class::STL::Element!"
			unless (UNIVERSAL::isa($self->data_type(), 'Class::STL::Element'));
		$self->data([]); # Array of (base) type Class::STL::Element
		foreach (@copy_containers) { $self->insert($self->begin(), $_->begin(), $_->end()); }
		foreach (@copy_elements) { $self->push($_); }
		if (@copy_iterators) {
			@copy_iterators >= 2 
				? $self->insert($self->begin(), $copy_iterators[0], $copy_iterators[1])
				: $self->insert($self->begin(), $copy_iterators[0]);
		}
		return $self;
	}
	sub append
	{
		my $self = shift;
		my $other = shift;
		$self->push($other->to_array());
		return $self;
	}
	sub clone
	{
		my $self = shift;
		return $self->new($self);
	}
	sub factory # (@params) -- construct an element object and return it;
	{
		my $self = shift;
		return $self->data_type() eq 'Class::STL::Element'
			? Class::STL::Element->new(@_)
			: eval("@{[ $self->data_type() ]}->new(\@_);");
	}
	sub push # (element [, ...] ) -- append elements to container...
	{
		my $self = shift;
		my $curr_sz = $self->size();
#?		CORE::push(@{$self->data()}, map($_->new($_), grep(ref && $_->isa('Class::STL::Element'), @_)));
		CORE::push(@{$self->data()}, grep(ref && $_->isa('Class::STL::Element'), @_));
		return $self->size() - $curr_sz; # number of new elements inserted.
	}
	sub pop # (void)
	{
		my $self = shift;
		CORE::pop(@{$self->data()});
		return; # void return
	}
	sub top # (void) -- top() and pop() refer to same element.
	{
		my $self = shift;
		return ${$self->data()}[$self->size()-1];
	}
	sub clear # (void)
	{
		my $self = shift;
		$self->data([]);
		return; # void return
	}
	sub insert # 
	{
		my $self = shift;
		my $position = shift;
		confess $self->_insert_errmsg()
		unless (defined($position) && ref($position) && $position->isa('Class::STL::Iterators::Abstract'));
		my $size = $self->size();

		# insert(position, iterator-start, iterator-finish);
		if (defined($_[0]) && ref($_[0]) && $_[0]->isa('Class::STL::Iterators::Abstract')
			&& defined($_[1]) && ref($_[1]) && $_[1]->isa('Class::STL::Iterators::Abstract'))
		{ 
			my $iter_start = shift;
			my $iter_finish = shift;
			my $pos = $self->size() ? $position->arr_idx() : 0;
			for (my $i = $iter_finish->new($iter_finish); $i >= $iter_start; --$i) {
				CORE::splice(@{$self->data()}, $pos, 0, 
					$i->p_element()->new($i->p_element())); # insert copies
			}
		}
		# insert(position, iterator-start);
		elsif (defined($_[0]) && ref($_[0]) && $_[0]->isa('Class::STL::Iterators::Abstract'))
		{ 
			my $iter_start = shift;
			for (my $i = $iter_start->new($iter_start); !$i->at_end(); ++$i) {
				if ($size)
				{
					CORE::splice(@{$self->data()}, $position->arr_idx(), 0, 
						$i->p_element()->new($i->p_element())); # insert copies
					$position++;
				}
				else
				{
					$self->push($i->p_element()->new($i->p_element()));
				}
			}
		}
		# insert(position, element [, ...]);
		elsif (defined($_[0]) && ref($_[0]) && $_[0]->isa('Class::STL::Element'))
		{ 
			!$size
				? $self->push(@_)
				: CORE::splice(@{$self->data()}, $position->arr_idx(), 0, 
					grep(ref && $_->isa('Class::STL::Element'), @_));
		}
		# insert(position, size, element);
		elsif (defined($_[0]) && defined($_[1]) && ref($_[1]) && $_[1]->isa('Class::STL::Element'))
		{ 
			my $num_repeat = shift;
			my $element = shift;
			for (my $i=0; $i < $num_repeat ; ++$i) {
				$size
					? CORE::splice(@{$self->data()}, $position->arr_idx(), 0, $element->new($element)) # insert copies
					: $self->push($element->new($element));
			}
		}
		else
		{
			confess $self->_insert_errmsg();
		}
		return; # void
	}
	sub swap # (container-ref) -- exchange self with container-ref
	{
		my $self = shift;
		my $other = shift;
		confess "@{[ __PACKAGE__ ]}::swap usage:\nswap( container-ref );"
		unless (defined($other) && ref($other) && $other->isa('Class::STL::Containers::Abstract'));
		my $tmp = $other->new($other);
		$other->clear();
		$other->push_back($self->to_array());
		$self->clear();
		$self->push_back($tmp->to_array());
		return;
	}
	sub erase # ( iterator | iterator-start, iterator-finish )
	{
		my $self = shift;
		my $iter_start = shift;
		my $iter_finish = shift || $iter_start->new($iter_start);
		confess "@{[ __PACKAGE__ ]}::erase usage:\nerase( iterator [, iterator ] );"
			unless (
				defined($iter_start) && ref($iter_start) && $iter_start->isa('Class::STL::Iterators::Abstract')
				&& defined($iter_finish) && ref($iter_finish) && $iter_finish->isa('Class::STL::Iterators::Abstract')
			);
		my $count=0;
		for (my $i = $iter_start->new($iter_start); $i <= $iter_finish; ++$i) {
			$count++;
		}
		CORE::splice(@{$self->data()}, $iter_start->arr_idx(), $count);
		$iter_start->set($iter_start->arr_idx());
#?		$iter_finish = $iter_start;
		return $count; # number of elements deleted
	}
	sub _insert_errmsg
	{
		return "@{[ __PACKAGE__ ]}::insert usage:\ninsert( position, element [, ...] );\n"
			. "insert( position, iterator-start, iterator-finish );\n"
			. "insert( position, size, element );\n";
	}
	sub begin # (void)
	{
		my $self = shift;
		return iterator(data => $self->data(), p_container => $self)->first();
	}
	sub end # (void)
	{
		# WARNING: end() points to last element unlike C++/STL-end() which points to AFTER last element!!
		# See examples/iterator.pl for correct iterator traversal example.
		my $self = shift;
		return iterator(data => $self->data(), p_container => $self)->last();
	}
	sub rbegin # (void)
	{
		my $self = shift;
		return reverse_iterator(data => $self->data(), p_container => $self)->first();
	}
	sub rend # (void)
	{
		my $self = shift;
		return reverse_iterator(data => $self->data(), p_container => $self)->last();
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
#TODO:sub to_array(iterator-start, iterator-finish);
	sub to_array # (void) -- maybe replace with foreach()
	{
		my $self = shift;
		my $level = shift || undef;

		return (@{$self->data()}) # array of data
			unless (defined($level));

		my @nodes;
		foreach (@{$self->data()}) { # traverse tree...
			($_->isa('Class::STL::Containers::Abstract'))
				? CORE::push(@nodes, $_->to_array($level+1)) 
				: CORE::push(@nodes, $_);
		}
		return @nodes;
	}
	sub eq # (vector)
	{
		my $self = shift;
		my $other = shift;
		return 0 unless $self->size() == $other->size();
		for (my $i1=$self->begin(), my $i2=$other->begin(); !$i1->at_end() && !$i2->at_end(); ++$i1, ++$i2)
		{
			return 0 unless ($i1->p_element()->eq($i2->p_element())); # not equal
		}
		return 1; # containers are equal
	}
	sub ne 
	{
		my $self = shift;
		return $self->eq(shift) ? 0 : 1;
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
	sub cmp
	{
		my $self = shift;
		my $other = shift;
		return $self->eq($other) ? 0 : $self->lt($other) ? -1 : 1;
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Vector;
	use base qw(Class::STL::Containers::Abstract); # vector is also an element
	sub BEGIN { Class::STL::Members::Disable->new( qw ( push_front ) ); }
	sub push_back # (element [, ...])
	{
		my $self = shift;
		return $self->push(@_); # number of new elements inserted.
	}
	sub pop_back # (void)
	{
		my $self = shift;
		$self->pop();
		return; # void return
	}
	sub back # (void)
	{
		my $self = shift;
		return ${$self->data()}[$self->size()-1]; # element ref
	}
	sub front # (void)
	{
		my $self = shift;
		return ${$self->data()}[0]; # element ref
	}
	sub at # (idx)
	{
		my $self = shift;
		my $idx = shift || 0;
		return ${$self->data()}[$idx]; # element ref
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Deque;
	use base qw(Class::STL::Containers::Vector);
	sub push_front # (element [, ...])
	{
		my $self = shift;
		my $curr_sz = $self->size();
		unshift(@{$self->data()}, grep(ref && $_->isa("Class::STL::Element"), @_));
		return $self->size() - $curr_sz; # number of new elements inserted.
	}
	sub pop_front # (void)
	{
		my $self = shift;
		my $front = shift(@{$self->data()});
		return; # void return
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Queue;
	use base qw(Class::STL::Containers::Abstract);
	sub BEGIN { Class::STL::Members::Disable->new( qw ( push_back pop_back ) ); }
	sub back # (void)
	{
		my $self = shift;
		return $self->SUPER::top();
	}
	sub front # (void)
	{
		my $self = shift;
		return ${$self->data()}[0]; # element ref
	}
	sub push # (element [,...]) -- push to back
	{
		my $self = shift;
		$self->SUPER::push(@_);
		return; # void return
	}
	sub pop # (void) -- pop from front
	{
		my $self = shift;
		shift(@{$self->data()});
		return; # void return
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Containers::Stack;
	use base qw(Class::STL::Containers::Abstract);
	sub BEGIN { Class::STL::Members::Disable->new( qw ( push_back pop_back front ) ); }
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
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_, data_type => __PACKAGE__);
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
	sub BEGIN { Class::STL::Members::Disable->new( qw ( at ) ); }
	sub reverse # (void)
	{
		my $self = shift;
		$self->data([ CORE::reverse(@{$self->data()}) ]);
	}
	sub sort # (void | cmp)
	{
		my $self = shift;
		$self->data([ CORE::sort { $a->cmp($b) } (@{$self->data()}) ]);
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
	sub BEGIN { Class::STL::DataMembers->new(qw( priority )); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		$self->members_init(@_);
#?		$self->priority(0) unless (defined($self->priority()));
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
	sub BEGIN { Class::STL::Members::Disable->new( qw ( push_back pop_back front ) ); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_, data_type => 'Class::STL::Element::Priority');
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
			for (my $i=$self->begin(); !$i->at_end(); ++$i)
			{
				if ($i->p_element()->gt($d))
				{
					$self->insert($i, $d);
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
		# sort according to cmp 
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
{
	package Class::STL::Containers::MakeFind;
	use UNIVERSAL qw(isa can);
	use Carp qw(cluck confess);
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		my $package = (caller())[0];
		confess "**Error: MakeFind is only available to classes derived from Class::STL::Containers::Abstract!\n"
			unless UNIVERSAL::isa($package, 'Class::STL::Containers::Abstract');
		my $this = $package;
		$this =~ s/[:]+/_/g;
		my $member_name = shift;
		my $code = "
			sub $package\::find 
			{
				my \$self = shift;
				my \$what = shift;
				return Class::STL::Algorithms::_find_if
				(
					\$self->begin(), \$self->end(),
			   		$package\::Find@{[ uc($member_name) ]}->new(what => \$what)
				);
			}
			{
				package $package\::Find@{[ uc($member_name) ]};
				use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
				sub BEGIN { Class::STL::DataMembers->new(qw( what )); }
				sub new
				{
					my \$self = shift;
					my \$class = ref(\$self) || \$self;
					\$self = \$class->SUPER::new(\@_);
					bless(\$self, \$class);
					\$self->members_init(\@_);
					return \$self;
				}
				sub function_operator
				{
					my \$self = shift;
					my \$arg = shift; # element object
					return \$arg->$member_name() eq \$self->what() ? \$arg : 0;
				}
			}";
		eval($code);
		cluck "**MakeFind Error:$@\n$code" if ($@);
	}
}
# ----------------------------------------------------------------------------------------------------
1;
