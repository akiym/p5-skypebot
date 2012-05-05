use strict;
use warnings;
use Skype::Any;
use Encode;

my $skype = Skype::Any->new;
$skype->message_received(sub {
    my $msg = shift;
    my $body = decode_utf8($msg->body);
    if ($body eq 'ping') {
        my $elapse_time = time() - $msg->timestamp;
        $msg->chat->send_message('pong: ' . $elapse_time . ' sec');
    }
});
$skype->run;
