use Module::Build;

my $build = Module::Build->new(
    dist_name => 'skypebot-dict',
    dist_version => '0.01',
    requires => {
        'AnyEvent'              => '',
        'AnyEvent::DBus'        => '',
        'LWP::UserAgent'        => '',
        'Net::DBus::Skype::API' => '',
        'Regexp::Common'        => '',
        'Skype::Any'            => '',
    },
);

$build->create_build_script;
