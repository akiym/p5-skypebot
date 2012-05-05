use strict;
use warnings;
use Encode;
use LWP::UserAgent;
use Skype::Any;

my $ua = LWP::UserAgent->new;

my $skype = Skype::Any->new;
$skype->message_received(sub {
    my $msg = shift;
    my $body = decode_utf8($msg->body);
    while ($body =~ m!(?=(https?://\S+))!g) {
        my $url = $1;
        my $res = $ua->get($url);
        $res->is_success or return;

        my ($title) = $res->decoded_content =~ m!<title>(.*?)</title>!i;
        $title // return;

        $msg->chat->send_message("$title");
    }
});
$skype->run;
