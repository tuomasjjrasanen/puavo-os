class veyon {
  include ::dpkg
  include ::packages
  include ::puavo_conf
  include ::puavo_pkg::packages

  file {
    '/etc/dbus-1/system.d/org.puavo.Veyon.conf':
      require => Package['dbus'],
      source  => 'puppet:///modules/veyon/org.puavo.Veyon.conf';

    '/etc/systemd/system/multi-user.target.wants/puavo-veyon.service':
      ensure  => 'link',
      require => [ File['/lib/systemd/system/puavo-veyon.service']
                 , Package['systemd'] ],
      target  => '/lib/systemd/system/puavo-veyon.service';

    '/lib/systemd/system/puavo-veyon.service':
      require => [ File['/usr/local/sbin/puavo-veyon']
                 , Package['systemd'] ],
      source  => 'puppet:///modules/veyon/puavo-veyon.service';

    '/usr/local/sbin/puavo-veyon':
      mode    => '0755',
      source  => 'puppet:///modules/veyon/puavo-veyon';
  }

  ::puavo_conf::definition {
    'puavo-veyon.json':
      source => 'puppet:///modules/veyon/puavo-veyon.json';
  }

  Package <|
       title == "dbus"
    or title == "veyon"
    or title == "x11vnc"
  |>

  Puavo_pkg::Install <| title == veyon |>
}
