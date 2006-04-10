# vim:ts=4 sw=4
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
$BUILD = 'Thursday April 06 21:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Algorithms;
	use UNIVERSAL qw(isa can);
	use vars qw( @EXPORT );
	use Exporter;
	@EXPORT = qw( 
		find find_if for_each transform count count_if 
		copy copy_backward
		remove remove_if remove_copy remove_copy_if
		replace replace_if replace_copy replace_copy_if 
	);
	sub transform 
	{
		return @_ == 5 ? transform_2(@_) : transform_1(@_);
	}
	sub transform_1 # (iterator-start, iterator-finish, iterator-result, unary-function-object)
	{
		_usage_check('transform', 'IIIU', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		my $unary_op = shift; # unary-function
		for (my $iter = $iter_finish->clone(); $iter >= $iter_start; --$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				transform_1($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result, $unary_op); # its a tree -- recurse
			}
			elsif ($unary_op->isa('Class::STL::Utilities::FunctionObject::UnaryPredicate'))
			{
				# Need to check this!
				my $e = $iter->p_element()->clone();
				$e->data($unary_op->function_operator($iter->p_element()) ? 1 : 0);
				$iter_result->p_container()->insert($iter_result, $e);
			}
			else # $unary_op->isa('Class::STL::Utilities::FunctionObject::UnaryFunction')
			{
				$iter_result->p_container()->insert($iter_result, 
					$unary_op->function_operator($iter->p_element()));
			}
		}
		return;
	}
	sub transform_2 # (iterator-start, iterator-finish, iterator-start2, iterator-result, binary-function-object)
	{
		_usage_check('transform', 'IIIIB', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_start2 = shift;
		my $iter_result = shift;
		my $binary_op = shift; # binary-function
		for 
		(
			my $iter=$iter_start->clone(), my $iter2=$iter_start2->clone(); 
			$iter <= $iter_finish && !$iter2->at_end(); 
			++$iter, ++$iter2
		)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				transform_2($iter->p_element()->begin(), $iter->p_element()->end(), $iter_start2, $iter_result, $binary_op); # its a tree -- recurse
			}
			elsif ($binary_op->isa('Class::STL::Utilities::FunctionObject::BinaryPredicate'))
			{
				my $e = $iter->p_element()->clone();
#>				$e->negate($binary_op->function_operator($iter->p_element(), $iter2->p_element()) ? 0 : 1);
				$e->data($binary_op->function_operator($iter->p_element(), $iter2->p_element()) ? 1 : 0);
				$iter_result = $iter_result->p_container()->insert($iter_result, $e);
				$iter_result++;	
			}
			else # $binary_op->isa('Class::STL::Utilities::FunctionObject::BinaryFunction')
			{
				$iter_result = $iter_result->p_container()->insert($iter_result, 
					$binary_op->function_operator($iter->p_element(), $iter2->p_element()));
				$iter_result++;	
			}
		}
		return;
	}
	sub for_each # (iterator, iterator, unary-function-object) -- static function
	{
		_usage_check('for_each', 'IIF', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
				? for_each($iter->p_element()->begin(), $iter->p_element()->end(), $function) # its a tree -- recurse
				: $function->function_operator($iter->p_element());
		}
		return;
	}
	sub find_if # (iterator, iterator, unary-function-object) -- static function
	{
		_usage_check('find_if', 'IIF', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function 
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{	# its a tree -- recurse
				if (my $i = find_if($iter->p_element()->begin(), $iter->p_element()->end(), $function))
				{
					return $i; # Need to check this !!
				}
			}
			elsif ($function->function_operator($iter->p_element()))
			{
				return $iter->clone();
			}
		}
		return 0;
	}
	sub find # (iterator, iterator, element-ref) -- static function
	{
		_usage_check('find', 'IIE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $element = shift; # element-ref
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				if (my $i = find($iter->p_element()->begin(), $iter->p_element()->end(), $element)) # its a tree -- recurse
				{
					return $i;
				}
			}
			elsif ($element->eq($iter->p_element()))
			{
				return $iter->clone();
			}
		}
		return 0;
	}
	sub count_if # (iterator, iterator, unary-function-object) -- static function
	{
		_usage_check('count_if', 'IIF', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function 
		my $count=0;
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			$count +=
				ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
					? count_if($iter->p_element()->begin(), $iter->p_element()->end(), $function) # its a tree -- recurse
					: ($function->function_operator($iter->p_element()) ? 1 : 0);
		}
		return $count;
	}
	sub count # (iterator, iterator, element-ref) -- static function
	{
		_usage_check('count', 'IIE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $element = shift; # unary-function 
		my $count=0;
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			$count +=
				ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
					? count($iter->p_element()->begin(), $iter->p_element()->end(), $element) # its a tree -- recurse
					: ($element->eq($iter->p_element()) ? 1 : 0);
		}
		return $count;
	}
	sub remove_if # (iterator, iterator, unary-function-object) -- static function
	{
		_usage_check('remove_if', 'IIF', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function or class-member-name
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; )
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				remove_if($iter->p_element()->begin(), $iter->p_element()->end(), $function); # its a tree -- recurse
				++$iter;
				next;
			}
			$function->function_operator($iter->p_element())
				? $iter->p_container()->erase($iter)
				: ++$iter;
		}
		return;
	}
	sub remove # (iterator, iterator, element-ref) -- static function
	{
		_usage_check('remove', 'IIE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $element = shift; # element-ref
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; )
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				remove($iter->p_element()->begin(), $iter->p_element()->end(), $element); # its a tree -- recurse
				++$iter;
				next;
			}
			$element->eq($iter->p_element())
				? $iter->p_container()->erase($iter)
				: ++$iter;
		}
		return;
	}
	sub remove_copy_if # (iterator, iterator, iterator, unary-function-object) -- static function
	{
		_usage_check('remove_copy_if', 'IIIF', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		my $function = shift; # unary-function or class-member-name
		for (my $iter = $iter_finish->clone(); $iter >= $iter_start; --$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				remove_copy_if($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result, $function); # its a tree -- recurse
			}
			elsif (!$function->function_operator($iter->p_element()))
			{
				$iter_result->p_container()->insert($iter_result, 1, $iter->p_element());
			}
		}
		return;
	}
	sub remove_copy # (iterator, iterator, iterator, element-ref) -- static function
	{
		_usage_check('remove_copy', 'IIIE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		my $element = shift; # element-ref
		for (my $iter = $iter_finish->clone(); $iter >= $iter_start; --$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				remove_copy($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result, $element); # its a tree -- recurse
			}
			elsif (!$element->eq($iter->p_element()))
			{
				$iter_result->p_container()->insert($iter_result, 1, $iter->p_element());
			}
		}
		return;
	}
	sub copy # (iterator, iterator, iterator) -- static function
	{
		_usage_check('copy', 'III', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		for (my $iter = $iter_finish->clone(); $iter >= $iter_start; --$iter)
		{
			ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
				? copy($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result) # its a tree -- recurse
				: $iter_result->p_container()->insert($iter_result, 1, $iter->p_element());
			$iter_result->first() if ($iter_result->at_end());
		}
		return;
	}
	sub copy_backward # (iterator, iterator, iterator) -- static function
	{
		_usage_check('copy_backward', 'III', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
				? copy_backward($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result) # its a tree -- recurse
				: $iter_result->p_container()->insert($iter_result, 1, $iter->p_element());
			$iter_result->first() if ($iter_result->at_end());
		}
		return;
	}
	sub replace_if # (iterator, iterator, unary-function, element-ref) -- static function
	{
		_usage_check('replace_if', 'IIFE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; 
		my $new_element = shift; # element-ref
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				replace_if($iter->p_element()->begin(), $iter->p_element()->end(), $function, $new_element); # its a tree -- recurse
			}
			elsif ($function->function_operator($iter->p_element()))
			{
				$iter->p_container()->erase($iter);
				$iter->p_container()->insert($iter, 1, $new_element);
			}
		}
		return;
	}
	sub replace # (iterator, iterator, element-ref, element-ref) -- static function
	{
		_usage_check('replace', 'IIEE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $old_element = shift; # element-ref
		my $new_element = shift; # element-ref
		for (my $iter = $iter_start->clone(); $iter <= $iter_finish; ++$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				replace($iter->p_element()->begin(), $iter->p_element()->end(), $old_element, $new_element); # its a tree -- recurse
			}
			elsif ($iter->p_element()->eq($old_element))
			{
				$iter->p_container()->erase($iter);
				$iter->p_container()->insert($iter, 1, $new_element);
			}
		}
		return;
	}
	sub replace_copy_if # (iterator, iterator, iterator, unary-function, element-ref) -- static function
	{
		_usage_check('replace_copy_if', 'IIIFE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		my $function = shift; 
		my $new_element = shift; # element-ref
		for (my $iter = $iter_finish->clone(); $iter >= $iter_start; --$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				replace_copy_if($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result, $function, $new_element); # its a tree -- recurse
			}
			elsif ($function->function_operator($iter->p_element()))
			{
				$iter_result->p_container()->insert($iter_result, 1, $new_element);
			}
			else
			{
				$iter_result->p_container()->insert($iter_result, 1, $iter->p_element());
			}
		}
		return;
	}
	sub replace_copy # (iterator, iterator, iterator, element-ref, element-ref) -- static function
	{
		_usage_check('replace_copy', 'IIIEE', @_);
		my $iter_start = shift;
		my $iter_finish = shift;
		my $iter_result = shift;
		my $old_element = shift; # element-ref
		my $new_element = shift; # element-ref
		for (my $iter = $iter_finish->clone(); $iter >= $iter_start; --$iter)
		{
			if (ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract'))
			{
				replace_copy($iter->p_element()->begin(), $iter->p_element()->end(), $iter_result, $old_element, $new_element); # its a tree -- recurse
			}
			elsif ($iter->p_element()->eq($old_element))
			{
				$iter_result->p_container()->insert($iter_result, 1, $new_element);
			}
			else
			{
				$iter_result->p_container()->insert($iter_result, 1, $iter->p_element());
			}
		}
		return;
	}
#TODO:sub sort
#TODO:{
#TODO:}
#TODO:sub reverse
#TODO:{
#TODO:}
#TODO:sub partition # (predicate)
#TODO:{
#TODO:}
#TODO:sub random_shuffle # ( [ random_number_generator ] )
#TODO:{
#TODO:}
#TODO:sub fill # ( [ size, ] value )
#TODO:{
#TODO:}
#TODO:sub generate # ( generator )
#TODO:{
#TODO:}
#TODO:sub generate_n # ( size, generator )
#TODO:{
#TODO:}
#TODO:sub min_element # ( [ binary_predicate ] ) -- use lt operator
#TODO:{
#TODO:}
#TODO:sub max_element # ( [ binary_predicate ] ) -- default use lt operator
#TODO:{
#TODO:}
#TODO:sub lower_bound
#TODO:{
#TODO:}
#TODO:sub upper_bound
#TODO:{
#TODO:}
	sub _usage_check
	{
		my $function_name = shift;
		my @format = split(//, shift);
		my $check=0;
		foreach my $arg (0..$#_) {
			++$check 
				if 
				(
					($format[$arg] eq 'I' && $_[$arg]->isa('Class::STL::Iterators::Abstract'))
					|| ($format[$arg] eq 'F' && $_[$arg]->isa('Class::STL::Utilities::FunctionObject'))
					|| ($format[$arg] eq 'B' && $_[$arg]->isa('Class::STL::Utilities::FunctionObject::BinaryFunction'))
					|| ($format[$arg] eq 'U' && $_[$arg]->isa('Class::STL::Utilities::FunctionObject::UnaryFunction'))
					|| ($format[$arg] eq 'E' && $_[$arg]->isa('Class::STL::Element'))
				)
		}
		if ($check != int(@_)) {
			use Carp qw(confess);
			my @anames;
			foreach (@format) { 
				push(@anames, 'iterator') if (/I/);
				push(@anames, 'function-object') if (/F/);
				push(@anames, 'unary-function-object') if (/U/);
				push(@anames, 'binnary-function-object') if (/B/);
				push(@anames, 'element-ref') if (/E/);
			}
			confess "@{[ __PACKAGE__]}::$function_name usage:\n$function_name( @{[ join(', ', @anames) ]});\n"
		}
	}
}
# ----------------------------------------------------------------------------------------------------
1;
