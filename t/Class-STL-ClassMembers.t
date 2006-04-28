# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Class-STL-Containers.t'

#########################

use Test;
use stl;
BEGIN { plan tests => 5 }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

{
	package MyPack;
	use Class::STL::ClassMembers (
			qw(msg_text msg_type),
			Class::STL::ClassMembers::DataMember->new(
				name => 'on', validate => '^(input|output)$', default => 'input'),
			Class::STL::ClassMembers::DataMember->new(
				name => 'display_target', default => 'STDERR'),
			Class::STL::ClassMembers::DataMember->new(
				name => 'count', validate => '^\d+$', default => '100'),
			Class::STL::ClassMembers::DataMember->new(
				name => 'comment', validate => '^\w+$', default => 'hello'),
			Class::STL::ClassMembers::FunctionMember::New->new(),
			Class::STL::ClassMembers::FunctionMember::Disable->new(qw(somfunc)),
	); 
}

my $att = MyPack->new();
ok ($att->member_print(), "comment=hello|count=100|display_target=STDERR|msg_text=NULL|msg_type=NULL|on=input", 'member_print()');

$att->count(25);
ok ($att->member_print(), "comment=hello|count=25|display_target=STDERR|msg_text=NULL|msg_type=NULL|on=input", 'put()');

ok ($att->comment(), "hello", 'get()');

ok ($att->comment($att->comment() . 'world'), "helloworld", 'put() + get()');

my $n = MyElem2->new(name => 'hello', name2 => 'world', data => '123');
ok (join(' ', $n->name(), $n->name2(), $n->data()), 'hello world 123', 'members_init()');

{
	package MyElem;
	use base qw(Class::STL::Element);
	use Class::STL::ClassMembers (
		qw(name),
		Class::STL::ClassMembers::FunctionMember::New->new(),
	); 
}
{
	package MyElem2;
	use base qw(MyElem);
	use Class::STL::ClassMembers (
		qw(name2 name3 add1 add2 zip country ),
		Class::STL::ClassMembers::FunctionMember::New->new(),
	); 
}
