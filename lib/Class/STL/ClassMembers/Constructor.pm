# vim:ts=4 sw=4
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::ClassMembers::Constructor.pm
#  Created	: 8 May 2006
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
use warnings;
use vars qw($VERSION $BUILD);
$VERSION = '0.21';
$BUILD = 'Monday May 8 23:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::ClassMembers::Constructor;
	use Class::STL::ClassMembers qw( constructor_name _caller _debug );
	use Carp qw(confess);
	use Class::STL::Trace;
	sub import
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->_caller((caller())[0]);
		$self->_debug(Class::STL::Trace->new(debug_on => 0));
		$self->constructor_name(shift || 'new');
		eval($self->code());
		confess "**Error in eval for @{[ $self->_caller() ]} FunctionMemeber constructor function creation:\n$@" if ($@);
		return $self;
	}
	sub code
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code;
		# new(void);
		# new(element_ref); -- copy ctor
		# new(raw_data);
		# new(option-pairs list);
		$code = "{\npackage @{[ $self->_caller() ]};\n";
		$code .= "sub @{[ $self->constructor_name() ]}\n";
		$code .= "{\n";
		$code .= "${tab}use vars qw(\@ISA);\n";
		$code .= "${tab}my \$proto = shift;\n";
		$code .= "${tab}return \$_[0]->clone() if (ref(\$_[0]) && \$_[0]->isa(__PACKAGE__));\n"; 
		$code .= "${tab}my \$class = ref(\$proto) || \$proto;\n";
		$code .= "${tab}my \$self = int(\@ISA) ? \$class->SUPER::new(\@_) : {};\n";
		$code .= "${tab}bless(\$self, \$class);\n";
		$code .= "${tab}\$self->members_init(\@_);\n";
		$code .= "${tab}@{[ $self->_caller() ]}::new_extra(\$self, \@_) if (defined(&@{[ $self->_caller() ]}::new_extra));\n";
		$code .= "${tab}return \$self;\n";
		$code .= "}\n";
		$code .= "}\n";
		$self->_debug()->print($self->_caller(), $code) if ($self->_debug()->debug_on());
		return $code;
	}
}
# ----------------------------------------------------------------------------------------------------
1;
