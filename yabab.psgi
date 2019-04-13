#! env perl

use utf8;
use common::sense;
use Dancer2;
use Template;
use DBD::SQLite;
use File::Slurper qw(read_dir);
my $dbh;

set database => 'smf.db';
set template => 'template_toolkit';
set session  => 'Simple';

get '/' => sub {

	my $dbh = &connect_db();

	my @boards;

	my $sql = qq{
	select *
	    from smf_boards
	};

	my $sth = $dbh->prepare($sql) || die $DBI::errstr;
	$sth->execute();

	while ( my $board = $sth->fetchrow_hashref() ) {
		push @boards, $board;
	}

	render( 'index', { boards => \@boards } );
};

get '/board/:id' => sub {

	my $board_id = route_parameters->get('id') // 1;

	my $data;
	( $data->{board} ) = query( sql => qq{select * from smf_boards where ID_BOARD = ?}, args => [$board_id] );

	$data->{topics} = [ &get_topics( sql => qq{and ID_BOARD = ? order by ID_FIRST_MSG desc}, args => [$board_id] ) ];

	
	render( 'board', $data );

};

get '/topic/:board/:topic' => sub {

	my $board_id = route_parameters->get('board') // 1;
	my $topic_id = route_parameters->get('topic') // 1;

	my $data;

	$data->{topic} = ( &get_topics( sql => qq{and ID_BOARD = ? and ID_TOPIC = ?}, args => [ $board_id, $topic_id ] ) )[0];

	$data->{messages} = [ &get_messages( sql => qq{and ID_TOPIC = ?}, args => [$topic_id] ) ];

	render( 'topic', $data );

};

start;

sub get_members {

	my (%pp) = @_;

	my $sql = qq{
	select *
	    from smf_members
	    where true
	    $pp{sql}
	};

	my @members = &query( sql => $sql, args => $pp{args} );

	return @members;

}

sub get_topics {

	my (%pp) = @_;

	my $sql = qq{
	select *
	    from smf_topics
	    where true
	    $pp{sql}
	};

	my @topics = &query( sql => $sql, args => $pp{args} );

	my %firsts     = map { $_->{ID_FIRST_MSG}      => 1 } @topics;
	my %member_ids = map { $_->{ID_MEMBER_STARTED} => 1 } @topics;

	my $msgs = qq{and ID_MSG in (} . join( ',', keys %firsts ) . qq{) order by posterTime};
	my %messages = map { $_->{ID_MSG} => $_ } &get_messages( sql => $msgs );

	my $mems = qq{and ID_MEMBER in (} . join( ',', keys %member_ids ) . qq{)};
	my %members = map { $_->{ID_MEMBER} => $_ } &get_members( sql => $mems );

	foreach my $topic (@topics) {
		$topic->{member} = $members{ $topic->{ID_MEMBER_STARTED} };
		$topic->{msg}    = $messages{ $topic->{ID_FIRST_MSG} };
		$topic->{name}   = $topic->{msg}->{subject};
	}

	return @topics;

}

sub get_messages {

	my (%pp) = @_;

	my $sql = qq{
	select *
	    from smf_messages
	    where true
	    $pp{sql}
	};

	my @messages = &query( sql => $sql, args => $pp{args} );

	my %member_ids = map { $_->{ID_MEMBER} => 1 } @messages;
	my $mems       = qq{and ID_MEMBER in (} . join( ',', keys %member_ids ) . qq{)};
	my %members    = map { $_->{ID_MEMBER} => $_ } &get_members( sql => $mems );

	foreach my $msg (@messages) {
		$msg->{member} = $members{ $msg->{ID_MEMBER} };
		$msg->{date} = localtime($msg->{posterTime});
	}

	return @messages;

}

sub query {

	my (%pp) = @_;

	my $dbh = &connect_db();

	my @items;

	my $sth = $dbh->prepare( $pp{sql} ) || die $DBI::errstr;
	$sth->execute( @{ $pp{args} } );

	while ( my $item = $sth->fetchrow_hashref() ) {
		push @items, $item;
	}

	$sth->finish();

	return @items;

}

sub connect_db {
	my $dbh = DBI->connect( "dbi:SQLite:dbname=" . setting('database'), '', '', { sqlite_unicode => 1 } )
	  or die $DBI::errstr;
	return $dbh;
}

sub render {

	my ( $key, $data, %pp ) = @_;

	my $tiny = Template->new( { ENCODING => 'utf8' } );

	my $tt = &templates();

	my $template = $tt->{header} . $tt->{$key} . $tt->{footer};

	my $output;

	$tiny->process( \$template, $data, \$output );

	return $output;

}

sub templates {

	my %tt;

	$tt{header} = qq{<!DOCTYPE html>\n<html>\n<body>\n};

	$tt{footer} = qq{\n</body></html>};

	$tt{err404} = qq{<h1>Not found</h1>};

	$tt{index} = qq{<h1>Index</h1>
			[% FOREACH i = boards %]
<h2><a href="/board/[% i.ID_BOARD %]">[% i.name %]</a></h2>
<p>[% i.description %]</p>
<p>[% i.numPosts %] posts in [% i.numTopics %] topics</p>
[% END %]
};

	$tt{board} = qq{<h1>[% board.name %]</h1>
			[% FOREACH i = topics %]
<h2><a href="/topic/[% board.ID_BOARD %]/[% i.ID_TOPIC %]">[% i.name %]</a> by [% i.member.memberName %] at [% i.msg.date %]</h2>
<hr>
[% END %]
};

	$tt{topic} = qq{<h1>[% topic.name %]</h1>
			[% FOREACH i = messages %]
<h2>[% i.subject %] by [% i.member.memberName %]</h2>
<section>[% i.body %]</section>
<hr>
[% END %]
};

	return \%tt;

}
