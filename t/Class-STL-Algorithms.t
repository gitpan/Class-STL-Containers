# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 6;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;
BEGIN { plan tests => 4 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list();
$l->push_back($l->factory(data => 'first'));
$l->push_back($l->factory(data => 'second'));
$l->push_back($l->factory(data => 'third'));
$l->push_back($l->factory(data => 'fourth'));
$l->push_back($l->factory(data => 'fifth'));

ok (find_if($l->begin(), $l->end(), MyFind->new(what => 'fourth'))->data(), 'fourth', 'find_if()');

ok (count_if($l->begin(), $l->end(), MyMatch->new(what => '^fi')), "2", 'count_if()');

remove_if($l->begin(), $l->end(), MyMatch->new(what => '^fi'));
ok (join('', map($_->data(), $l->to_array())), "secondthirdfourth", 'remove_if()');

transform($l->begin(), $l->end(), MyUFunc->new());
ok (join('', map($_->data(), $l->to_array())), "SECONDTHIRDFOURTH", 'foreach()');

{
	package MyMatch;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub BEGIN { Class::STL::DataMembers->new( qw( what ) ); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		return ($arg->data() =~ /@{[ $self->what() ]}/i) ? $arg : 0;
	}
}
{
	package MyFind;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub BEGIN { Class::STL::DataMembers->new( qw( what ) ); }
	sub new
	{
		my $self = shift;
		my $class = ref($self) || $self;
		$self = $class->SUPER::new(@_);
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		return $arg->data() eq $self->what() ? $arg : 0;
	}
}
{
	package MyUFunc;
	use base qw(Class::STL::Utilities::FunctionObject::UnaryFunction);
	sub function_operator
	{
		my $self = shift;
		my $arg = shift;
		$arg->data(uc($arg->data()));
	}
}
