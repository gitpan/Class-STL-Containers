# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

use Test;
use Class::STL::DataMembers;
BEGIN { plan tests => 4 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

{
	package MyPack;
	sub BEGIN 
	{ 
		Class::STL::DataMembers->new(
			qw(msg_text msg_type),
			Class::STL::DataMembers::Attributes->new(
				name => 'on', validate => '^(input|output)$', default => 'input'),
			Class::STL::DataMembers::Attributes->new(
				name => 'display_target', default => 'STDERR'),
			Class::STL::DataMembers::Attributes->new(
				name => 'count', validate => '^\d+$', default => '100'),
			Class::STL::DataMembers::Attributes->new(
				name => 'comment', validate => '^\w+$', default => 'hello'),
		); 
	}
	sub new
	{
		my $proto = shift;
		my $class = ref($proto) || $proto;
		my $self = {};
		bless($self, $class);
		$self->members_init(@_);
		return $self;
	}
}

my $att = MyPack->new();
ok ($att->member_print(), "comment=hello|count=100|display_target=STDERR|msg_text=NULL|msg_type=NULL|on=input", 'member_print()');

$att->count(25);
ok ($att->member_print(), "comment=hello|count=25|display_target=STDERR|msg_text=NULL|msg_type=NULL|on=input", 'put()');

ok ($att->comment(), "hello", 'get()');

ok ($att->comment($att->comment() . 'world'), "helloworld", 'put() + get()');
