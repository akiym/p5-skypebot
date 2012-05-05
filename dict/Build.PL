use Module::Build;

my $build = Module::Build->new(
    dist_name => 'skypebot-dict',
    dist_version => '0.01',
    requires => {
        'AnyEvent'                     => '',
        'AnyEvent::DBus'               => '',
        'LWP::UserAgent'               => '',
        'Lingua::JA::Regular::Unicode' => '',
        'Net::DBus::Skype::API'        => '',
        'Skype::Any'                   => '',
        'URI'                          => '',
        'XML::Simple'                  => '',
    },
);

$build->create_build_script;
