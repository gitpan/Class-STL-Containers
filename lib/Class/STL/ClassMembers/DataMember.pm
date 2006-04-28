# vim:ts=4 sw=4
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::ClassMembers::DataMember.pm
#  Created	: 27 April 2006
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
use vars qw( $VERSION $BUILD );
$VERSION = '0.18';
$BUILD = 'Thursday April 27 23:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::ClassMembers::DataMember;
	use Class::STL::ClassMembers qw( name default validate _caller );
	use Carp qw(confess);
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->members_init(_caller => (caller())[0], @_);
		return $self;
	}
	sub init_func_code
	{
		my $self = shift;
		return "\$self->@{[ $self->name() ]}("
			. (defined($self->default())
				? "exists(\$p{'@{[ $self->name() ]}'}) ? \$p{'@{[ $self->name() ]}'} : '@{[ $self->default() ]}'"
				: "\$p{'@{[ $self->name() ]}'}")
			. ");";
	}
	sub accessor_func_code
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "${tab}if (\@_) {\n";
		$code .= "${tab}${tab}die \"**Field '@{[ $self->name() ]}' value '\$_[0]' failed validation ('\" . '@{[ $self->validate() ]}' . \"')\"\n";
		$code .= "${tab}${tab}${tab}unless (\$_[0] =~ /@{[ $self->validate() ]}/);\n";
		$code .= "${tab}${tab}\$self->{@{[ $self->_caller_str() ]}}->{@{[ uc($self->name()) ]}} = shift;\n";
		$code .= "${tab}}\n";
		return $code;
	}
	sub _caller_str
	{
		my $self = shift;
		my $str = $self->_caller();
		$str =~ s/[:]+/_/g;
		return $str;
	}
}
1;
__END__
