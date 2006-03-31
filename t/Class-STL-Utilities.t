# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 5;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Containers;
use Class::STL::Algorithms;
use Class::STL::Utilities;
BEGIN { plan tests => 11 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = list();
$l->push_back($l->factory(data => 'first'));
$l->push_back($l->factory(data => 'second'));
$l->push_back($l->factory(data => 'third'));
$l->push_back($l->factory(data => 'fourth'));
$l->push_back($l->factory(data => 'fifth'));

remove_if($l->begin(), $l->end(), MyMatch->new(what => '^fi'));
ok (join('', map($_->data(), $l->to_array())), "secondthirdfourth", 'matches()');

my $f = $l->factory(data=>'third');
remove_if($l->begin(), $l->end(), bind1st(equal_to(), $f));
ok (join('', map($_->data(), $l->to_array())), "secondfourth", 'equal_to()');

{
	package MyClass;
	use base qw(Class::STL::Element);
	use base qw(Class::STL::Utilities);
}
my $e = MyClass->new(data => 100, data_type => 'numeric');
my $e2 = MyClass->new($e);
my $e3 = MyClass->new(data => 101, data_type => 'numeric');
ok (equal_to()->function_operator($e, $e2), "1", "equal_to()");
ok (not_equal_to()->function_operator($e, $e2), "", "not_equal_to()");
ok (greater()->function_operator($e3, $e2), "1", "greater()"); # $e3 > $e2
ok (less()->function_operator($e2, $e3), "1", "less()"); # $e2 < $e3
ok (greater_equal()->function_operator($e3, $e2), "1", "greater_equal()");
ok (less_equal()->function_operator($e2, $e3), "1", "less_equal()");
ok (compare()->function_operator($e2, $e3), "-1", "compare()"); # $e2 < $e3
ok (compare()->function_operator($e3, $e), "1", "compare()"); # $e3 > $e
ok (compare()->function_operator($e2, $e), "0", "compare()");

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
