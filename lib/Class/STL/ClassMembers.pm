# vim:ts=4 sw=4
# ----------------------------------------------------------------------------------------------------
#  Name		: Class::STL::ClassMembers.pm
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
use vars qw($VERSION $BUILD);
$VERSION = '0.18';
$BUILD = 'Thursday April 27 23:08:34 GMT 2006';
# ----------------------------------------------------------------------------------------------------
{
	package Class::STL::ClassMembers;
	use UNIVERSAL qw(isa can);
	use Carp qw(confess);
	sub import
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->_caller((caller())[0]);
		$self->_debug(0);
		$self->_members(grep(!ref($_) || (ref($_) && !$_->isa('Class::STL::ClassMembers::FunctionMember::Abstract')), @_));
		$self->_code([]);
		push(@{$self->_code()}, 
			map($_->code($self->_caller()), 
				grep(ref($_) && $_->isa('Class::STL::ClassMembers::FunctionMember::Abstract'), @_))); 
		$self->_prepare();
		return $self;
	}
	# ----------------------------------------------------------------------------------------------------
	# PRIVATE
	# ----------------------------------------------------------------------------------------------------
	sub _prepare
	{
		my $self = shift;
		confess __PACKAGE__ . " usage:\nnew(<data member name list>);\n***Error empty data member names list!\n"
			unless (keys(%{$self->_members()}));

		map($self->_public_member_func($_), values(%{$self->_members()}));
		$self->_init_func();
		$self->_print_func();
		$self->_members_func();
		$self->_swap_func();
		$self->_clone_func();
		$self->_ignore_local_func();

		unshift(@{$self->_code()}, "{\npackage @{[ $self->_caller() ]};\n");
		push(@{$self->_code()}, "}\n");

		if ($self->_debug())
		{
			open(DEBUG, ">>datemembers$$.out");
			print DEBUG "# @{[ $self->_caller() ]} data members (", 
				join(', ', keys( %{$self->_members()} )), ")\n";
			print DEBUG join("", @{$self->_code()}), "\n";
			close(DEBUG);
		}
		eval(join("", @{$self->_code()}));
		confess "**Error in eval for @{[ $self->_caller() ]} ClassMembers functions creation:\n$@" if ($@);
	}
	sub _code
	{
		my $self = shift;
		$self->{__PACKAGE__}->{CODE} = shift if (@_);
		return $self->{__PACKAGE__}->{CODE};
	}
	sub _debug
	{
		my $self = shift;
		$self->{__PACKAGE__}->{DEBUG} = shift if (@_);
		return $self->{__PACKAGE__}->{DEBUG};
	}
	sub _caller
	{
		my $self = shift;
		$self->{__PACKAGE__}->{CALLER} = shift if (@_);
		return $self->{__PACKAGE__}->{CALLER};
	}
	sub _caller_str
	{
		my $self = shift;
		my $str = $self->_caller();
		$str =~ s/[:]+/_/g;
		return $str;
	}
	sub _members
	{
		my $self = shift;
		if (@_)
		{
			foreach my $member (@_)
			{
				ref($member) && $member->isa('Class::STL::ClassMembers::DataMember')
					?  $self->{MEMBERS}->{$member->name()} = $member
					:  $self->{MEMBERS}->{$member} = $member;
			}
		}
		return $self->{MEMBERS};
	}
	sub _public_member_func
	{
		my $self = shift;
		my $member = shift;
		my $tab = ' ' x 4;
		my $member_name = ref($member) && $member->isa('Class::STL::ClassMembers::DataMember') 
			? $member->name() : $member;
		my $code = "sub $member_name {\n${tab}my \$self = shift;\n";

		if (ref($member) && $member->isa('Class::STL::ClassMembers::DataMember') && defined($member->validate()))
		{
			$code .= $member->accessor_func_code();
		}
		else
		{
			$code .= "${tab}\$self->{@{[ $self->_caller_str() ]}}->{@{[ uc($member_name) ]}} = shift if (\@_);\n";
		}
		$code .= "${tab}return \$self->{@{[ $self->_caller_str() ]}}->{@{[ uc($member_name) ]}};\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
	sub _init_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub members_init {\n";
		$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}use vars qw(\@ISA);\n";
		$code .= "${tab}if (int(\@ISA) && (caller())[0] ne __PACKAGE__) {\n";
		$code .= "${tab}${tab}\$self->SUPER::members_init(\@_);\n";
		$code .= "${tab}}\n";
		$code .= "${tab}my \@p;\n";
		$code .= "${tab}while (\@_) { my \$p=shift; push(\@p, \$p, shift) if (!ref(\$p)); }\n";
		$code .= "${tab}my \%p = \@p;\n";
		$code .= "${tab}@{[ join(\"\n    \", map($self->_member_init_func($_), values( %{$self->_members()} ))) ]}\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
	sub _member_init_func
	{
		my $self = shift;
		my $member = shift;
		my $member_name = ref($member) && $member->isa('Class::STL::ClassMembers::DataMember') 
			? $member->name() : $member;
		return ref($member) && $member->isa('Class::STL::ClassMembers::DataMember')
			? $member->init_func_code()
			: "\$self->$member_name(\$p{'$member_name'});";
	}
	sub _print_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub member_print {\n";
		$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}my \$delim = shift || '|';\n";
		$code .= "${tab}return join(\"\$delim\",\n${tab}${tab}";
		$code .= 
			join(qq/,\n$tab$tab/, 
				map
				(
					qq/"$_=\@{[ defined(\$self->$_()) ? \$self->$_() : 'NULL' ]}"/, 
					sort(map(ref($_) ? $_->name() : $_, values( %{$self->_members()} )))
				)
			);
		$code .= "\n${tab});\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
	sub _members_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub members { # static function\n";
    	$code .= "${tab}return {\n${tab}${tab}";
		$code .= join
		(
			",\n${tab}${tab}", 
			map
			(
				"$_=>[ " 
					. (ref(${$self->_members()}{$_}) && ${$self->_members()}{$_}->isa('Class::STL::ClassMembers::DataMember') 
						? "'@{[ defined(${$self->_members()}{$_}->default()) ? ${$self->_members()}{$_}->default() : q## ]}', "
							. "'@{[ defined(${$self->_members()}{$_}->validate()) ? ${$self->_members()}{$_}->validate() : q## ]}'" : '')
					. " ]", 
				sort keys(%{$self->_members()})
			)
		);
		$code .= "\n${tab}}\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
	sub _swap_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub swap {\n";
		$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}my \$other = shift;\n";
		$code .= "${tab}use vars qw(\@ISA);\n";
		$code .= "${tab}my \$tmp = int(\@ISA) ? \$self->SUPER\::swap(\$other) : \$self->clone();\n";
		$code .= "${tab}@{[ join(qq#\n${tab}#, 
			map(qq#\$self->$_(\$other->$_());#, keys( %{$self->_members()} ) )) ]}\n";
		$code .= "${tab}@{[ join(qq#\n${tab}#, 
			map(qq#\$other->$_(\$tmp->$_());#, keys( %{$self->_members()} ) )) ]}\n";
		$code .= "${tab}return \$tmp;\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
	sub _clone_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub clone {\n";
		$code .= "${tab}my \$self = shift;\n";
		$code .= "${tab}my \$clone = \$self->new(\$self);\n";
		$code .= "${tab}@{[ join(qq#\n${tab}#, 
			map(qq#\$clone->$_(\$self->$_());#, keys( %{$self->_members()} ) )) ]}\n";
		$code .= "${tab}return \$clone;\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
	sub _ignore_local_func
	{
		my $self = shift;
		my $tab = ' ' x 4;
		my $code = "sub ignore_local { # static function\n";
		$code .= "${tab}my \@ign;\n";
		$code .= "${tab}foreach (\@_) { !ref(\$_) && exists(\${members()}{\$_}) ? shift : push(\@ign, \$_); }\n";
		$code .= "${tab}return \@ign;\n";
		$code .= "}\n";
		push(@{$self->_code()}, $code);
		return;
	}
}
# ----------------------------------------------------------------------------------------------------
1;
