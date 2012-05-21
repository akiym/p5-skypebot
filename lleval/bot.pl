use strict;
use 5.10.0;
use Skype::Any;
use LLEval;
use LWP::UserAgent;
use Encode qw(encode_utf8 decode_utf8);

use constant _DEBUG => $ENV{LLEVAL_BOT_DEBUG};
use if _DEBUG, 'Data::Dumper';


# original script taken from (gfx++)
# http://d.hatena.ne.jp/gfx/20111120/1321795431

my $lleval = LLEval->new();
my $ua = LWP::UserAgent->new();

my %languages = %{$lleval->languages};
my $langs     = '(?:' . join('|', map { quotemeta } keys %languages) . ')';

sub receiver {
    my($msg) = @_;
    my($lang, $src) = $msg->body =~ /\A ($langs) \s+ (.+)/xms or return;

    say "$lang $src" if _DEBUG;
    my $result = $lleval->call_eval( decode_utf8($src), $lang );

    if(_DEBUG) {
        say Data::Dumper->new([$result])
                ->Indent(1)
                ->Sortkeys(1)
                ->Quotekeys(0)
                ->Useqq(1)
                ->Terse(1)
                ->Dump();
    }

    if(defined(my $s = $result->{stdout})) {
        $msg->chat->send_message(encode_utf8($s));
    }

    # error?
    if($result->{status}) {
        $msg->chat->send_message("$languages{$lang} returned $result->{status} :/");
    }
    if($result->{error}) {
        $msg->chat->send_message("error: $result->{error}");
    }
    #if(defined(my $s = $result->{stderr})) {
    #    $msg->chat->send_message(encode_utf8($s));
    #}
}

my $skype = Skype::Any->new();

$skype->message_received(\&receiver);

$skype->run;
