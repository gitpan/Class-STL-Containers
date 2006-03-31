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
package Class::STL::Utilities;
require 5.005_62;
use strict;
use warnings;
use vars qw( $VERSION $BUILD @EXPORT );
use Exporter;
@EXPORT = qw( equal_to not_equal_to greater greater_equal less less_equal compare bind1st bind2nd mem_fun );
use lib './lib';
use Class::STL::DataMembers;
$VERSION = '0.01';
$BUILD = 'Wednesday February 22 15:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities;
	use vars qw( $AUTOLOAD );
	sub AUTOLOAD
	{
		(my $func = $AUTOLOAD) =~ s/.*:://;
		return Class::STL::Utilities::EqualTo->new(@_) if ($func eq 'equal_to');
		return Class::STL::Utilities::NotEqualTo->new(@_) if ($func eq 'not_equal_to');
		return Class::STL::Utilities::Greater->new(@_) if ($func eq 'greater');
		return Class::STL::Utilities::GreaterEqual->new(@_) if ($func eq 'greater_equal');
		return Class::STL::Utilities::Less->new(@_) if ($func eq 'less');
		return Class::STL::Utilities::LessEqual->new(@_) if ($func eq 'less_equal');
		return Class::STL::Utilities::Compare->new(@_) if ($func eq 'compare');
#?		return Class::STL::Utilities::Matches->new(@_) if ($func eq 'matches');
		return Class::STL::Utilities::Binder1st->new(@_) if ($func eq 'bind1st');
		return Class::STL::Utilities::Binder2nd->new(@_) if ($func eq 'bind2nd');
		return Class::STL::Utilities::MemberFunction->new(@_) if ($func eq 'mem_fun');
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::FunctionObject;
	sub BEGIN { Class::STL::DataMembers->new(qw( result_type )); }
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		use Carp qw(confess);
		confess "@{[ __PACKAGE__ ]} abstract class must be derived!\n";
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::FunctionObject::UnaryFunction;
	use base qw(Class::STL::Utilities::FunctionObject);
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift;
		use Carp qw(confess);
		confess "@{[ __PACKAGE__ ]} abstract class must be derived!\n";
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::FunctionObject::BinaryFunction;
	use base qw(Class::STL::Utilities::FunctionObject);
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift;
		my $arg2 = shift;
		use Carp qw(confess);
		confess "@{[ __PACKAGE__ ]} abstract class must be derived!\n";
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::FunctionObject::UnaryPredicate;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_, result_type => 'bool');
		bless($self, $class);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift;
		use Carp qw(confess);
		confess "@{[ __PACKAGE__ ]} abstract class must be derived!\n";
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::FunctionObject::BinaryPredicate;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryFunction);
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_, result_type => 'bool');
		bless($self, $class);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift;
		my $arg2 = shift;
		use Carp qw(confess);
		confess "@{[ __PACKAGE__ ]} abstract class must be derived!\n";
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::MemberFunction;
	use base qw(Class::STL::Utilities::FunctionObject);
	sub BEGIN { Class::STL::DataMembers->new(qw( function_name )); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new();
		bless($self, $class);
		$self->members_init(function_name => shift);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $element = shift;
		my $fname = $self->function_name();
		return $element->$fname(@_);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Binder1st;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub BEGIN { Class::STL::DataMembers->new(qw( operation first_argument )); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new();
		bless($self, $class);
		$self->members_init(operation => shift, first_argument => shift);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg = shift; # element object
		return $self->operation()->function_operator($self->first_argument(), $arg);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Binder2nd;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub BEGIN { Class::STL::DataMembers->new(qw( operation second_argument )); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new();
		bless($self, $class);
		$self->members_init(operation => shift, second_argument => shift);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg = shift; # element object
		return $self->operation()->function_operator($arg, $self->second_argument());
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::EqualTo;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->eq($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::NotEqualTo;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->ne($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Greater;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->gt($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::GreaterEqual;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->ge($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Less;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->lt($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::LessEqual;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->le($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Compare;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # element object
		return $arg1->cmp($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::Utilities::Matches;
	use base qw(Class::STL::Utilities::FunctionObject::BinaryPredicate);
	sub function_operator
	{
		my $self = shift;
		my $arg1 = shift; # element object
		my $arg2 = shift; # regular expression string
		return $arg1->match($arg2);
	}
}
# ----------------------------------------------------------------------------------------------------
1;
