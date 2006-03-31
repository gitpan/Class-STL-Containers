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
$BUILD = 'Wednesday February 22 15:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Algorithms;
	use UNIVERSAL qw(isa can);
	use vars qw( @EXPORT );
	use Exporter;
	@EXPORT = qw( remove_if find_if foreach transform count_if );

	sub _usage_check
	{
		my $function_name = shift;
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift;
		use Carp qw(confess);
		confess "@{[ __PACKAGE__]}::$function_name usage:\n$function_name( iterator, iterator, unary-function-object );\n"
			unless (
				defined($iter_start) && ref($iter_start) && $iter_start->isa('Class::STL::Iterators::Abstract')
				&& defined($iter_finish) && ref($iter_finish) && $iter_finish->isa('Class::STL::Iterators::Abstract')
				&& defined($function) && ref($function) && $function->isa('Class::STL::Utilities::FunctionObject')
			);
	}
	sub transform # (iterator, iterator, unary-function-object) -- static function
	{
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function or class-member-name
		_usage_check('transform', $iter_start, $iter_finish, $function);
		for (my $iter = $iter_start->new($iter_start); $iter <= $iter_finish; ++$iter)
		{
			ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
				? transform($iter->p_element()->begin(), $iter->p_element()->end(), $function) # its a tree -- recurse
				: $function->function_operator($iter->p_element());
		}
		return;
	}
	sub foreach # (iterator, iterator, unary-function-object) -- static function
	{
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function or class-member-name
		_usage_check('foreach', $iter_start, $iter_finish, $function);
		for (my $iter = $iter_start->new($iter_start); $iter <= $iter_finish; ++$iter)
		{
			ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
				? &foreach($iter->p_element()->begin(), $iter->p_element()->end(), $function) # its a tree -- recurse
				: $function->function_operator($iter->p_element());
		}
		return;
	}
	sub find_if # (iterator, iterator, unary-function-object) -- static function
	{
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function or class-member-name
		_usage_check('find_if', $iter_start, $iter_finish, $function);
		for (my $iter = $iter_start->new($iter_start); $iter <= $iter_finish; ++$iter)
		{
			if (my $elem = 
				ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
					? find_if($iter->p_element()->begin(), $iter->p_element()->end(), $function) # its a tree -- recurse
					: $function->function_operator($iter->p_element()))
			{
				return $elem;
			}
		}
		return 0;
	}
	sub count_if # (iterator, iterator, unary-function-object) -- static function
	{
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function or class-member-name
		_usage_check('count_if', $iter_start, $iter_finish, $function);
		my $count=0;
		for (my $iter = $iter_start->new($iter_start); $iter <= $iter_finish; ++$iter)
		{
			$count +=
				ref($iter->p_element()) && $iter->p_element()->isa('Class::STL::Containers::Abstract')
					? count_if($iter->p_element()->begin(), $iter->p_element()->end(), $function) # its a tree -- recurse
					: ($function->function_operator($iter->p_element()) ? 1 : 0);
		}
		return $count;
	}
	sub remove_if # (iterator, iterator, unary-function-object) -- static function
	{
		my $iter_start = shift;
		my $iter_finish = shift;
		my $function = shift; # unary-function or class-member-name
		_usage_check('remove_if', $iter_start, $iter_finish, $function);
		for (my $iter = $iter_start->new($iter_start); $iter <= $iter_finish; )
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
}
# ----------------------------------------------------------------------------------------------------
1;
