# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

#use Test::More tests => 6;
#BEGIN { use_ok('Class::STL::Containers') };
#BEGIN { use_ok('Class::STL::Algorithms') };
#BEGIN { use_ok('Class::STL::Utilities') };

use Test;
use Class::STL::Containers;
BEGIN { plan tests => 3 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $l = Class::STL::Containers::List->new();
$l->push_back($l->factory(data => 'first'));
$l->push_back($l->factory(data => 'second'));
$l->push_back($l->factory(data => 'third'));
$l->push_back($l->factory(data => 'fourth'));
$l->push_back($l->factory(data => 'fifth'));

ok ($l->find_if(MyFind->new('fourth'))->data(), 'fourth', 'find_if()');

$l->remove_if($l->matches('^fi'));
ok (join('', $l->to_array()), "secondthirdfourth", 'remove_if()');

$l->foreach(MyUFunc->new());
ok (join('', $l->to_array()), "SECONDTHIRDFOURTH", 'foreach()');

{
	package MyFind;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		return $elem->data() eq $self->arg() ? $elem : 0;
	}
}
{
	package MyUFunc;
	use base qw(Class::STL::Utilities::UnaryFunction);
	sub do
	{
		my $self = shift;
		my $elem = shift;
		$elem->data(uc($elem->data()));
	}
}
