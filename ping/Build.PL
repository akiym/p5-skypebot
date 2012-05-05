use Module::Build;

my $build = Module::Build->new(
    dist_name => 'skypebot-ping',
    dist_version => '0.01',
    requires => {
        'AnyEvent'              => '',
        'AnyEvent::DBus'        => '',
        'Net::DBus::Skype::API' => '',
        'Skype::Any'            => '',
    },
);

$build->create_build_script;
