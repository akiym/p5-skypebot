use strict;
use warnings;
use utf8;
use Encode;
use Lingua::JA::Regular::Unicode qw/alnum_z2h/;
use LWP::UserAgent;
use Skype::Any;
use XML::Simple ();
use URI;
use URI::QueryParam;

our %DICT_TYPE = (e2j => 'EJdict', j2e => 'EdictJE');

my $ua = LWP::UserAgent->new;
my $api_url = 'http://public.dejizo.jp/NetDicV09.asmx';

my $skype = Skype::Any->new;
$skype->message_received(sub {
    my $msg = shift;
    if (my ($word) = decode_utf8($msg->body) =~ /^dict:\s*(.+)/) {
        my $type = $word =~ /^[a-zA-Z0-9_]+$/ ? 'e2j' : 'j2e'; # don't use \w
        my $user = Skype::Any::User->new($msg->from_handle);
        if (my $item_id = get_item_id($word, $type)) {
            my $body = get_body($item_id, $type);
            $body = alnum_z2h($body);
            $user->send_message(encode_utf8($body));
        } else {
            $user->send_message('Sorry, did not match... ;(');
        }
    }
});
$skype->run;

sub get_item_id {
    my ($word, $type) = @_;

    my $uri = URI->new("$api_url/SearchDicItemLite");
    $uri->query_form_hash({
        Dic       => $DICT_TYPE{$type},
        Word      => $word,
        Scope     => 'HEADWORD',
        Match     => 'STARTWITH',
        Merge     => 'AND',
        Prof      => 'XHTML',
        PageSize  => 1,
        PageIndex => 0,
    });
    my $res = $ua->get($uri);
    return unless $res->is_success;

    my $xml = XML::Simple::XMLin($res->content);
    return if $xml->{ItemCount} == 0;

    $xml->{TitleList}{DicItemTitle}{ItemID};
}

sub get_body {
    my ($item_id, $type) = @_;

    my $uri = URI->new("$api_url/GetDicItemLite");
    $uri->query_form_hash({
        Dic  => $DICT_TYPE{$type},
        Item => $item_id,
        Loc  => '',
        Prof => 'XHTML',
    });
    my $res = $ua->get($uri);
    return unless $res->is_success;

    my $xml = XML::Simple::XMLin(
        $res->content,
        SuppressEmpty => 1, # returns empty element.
    );

    if ($type eq 'e2j') {
        my $caption = $xml->{Head}->{div}{span}{content};
        if ($caption =~ s/\.$//) {
            my @results = split /\s+/, $xml->{Body}->{div}{div};
            sprintf '%d results: %s', scalar @results, join ', ', @results;
        } else {
            sprintf '[%s] %s', $caption, join "\n", split /\s+/, $xml->{Body}->{div}{div};
        }
    } else {
        (my $caption = $xml->{Head}->{div}{span}{content}) =~ s/\n*\s+.*$//ms;
        my $stuff = $xml->{Body}->{div}{div}{div};
        if (ref $stuff eq 'ARRAY') {
            sprintf '[%s] %s', $caption, join ', ', @{$xml->{Body}->{div}{div}{div}};
        } else {
            sprintf '[%s] %s', $caption, $stuff;
        }
    }
}
