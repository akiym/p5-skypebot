use Module::Build;

my $build = Module::Build->new(
    dist_name => 'skypebot-dict',
    dist_version => '0.01',
    requires => {
        'AnyEvent'              => '',
        'AnyEvent::DBus'        => '',
        'LLEval'                => '',
        'LWP::UserAgent'        => '',
        'Net::DBus::Skype::API' => '',
        'Skype::Any'            => '',
    },
);

$build->create_build_script;
