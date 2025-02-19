class docker {
  include ::docker::collabora
  include ::docker::nextcloud

  $docker_ip = '172.17.0.1'
  $docker_ip_with_cidr = "${docker_ip}/16"

  file {
    '/etc/puavo-docker':
      ensure => directory;

    '/etc/puavo-docker/docker-compose.yml.tmpl':
      content => template('docker/docker-compose.yml.tmpl'),
      require => File['/etc/puavo-docker/files/Dockerfile.nextcloud'];

    '/etc/puavo-docker/files':
      ensure => directory;

    '/etc/systemd/system/puavo-docker.service':
      source => 'puppet:///modules/docker/puavo-docker.service';

    '/etc/systemd/system/puavo-docker.timer':
      source => 'puppet:///modules/docker/puavo-docker.timer';

    '/etc/systemd/system/timers.target.wants/puavo-docker.timer':
      ensure  => 'link',
      require => [ File['/etc/systemd/system/puavo-docker.timer']
                 , Package['systemd'] ],
      target  => '/etc/systemd/system/puavo-docker.timer';

    '/usr/local/sbin/puavo-docker':
      mode    => '0755',
      require => [ File['/etc/puavo-docker/docker-compose.yml.tmpl']
                 , Package['ruby-net-ldap'] ],
      source  => 'puppet:///modules/docker/puavo-docker';
  }

  ::puavo_conf::definition {
    'puavo-docker.json':
      source => 'puppet:///modules/docker/puavo-docker.json';
  }

  Package <|
       title == 'docker-compose'
    or title == 'docker.io'
    or title == 'ruby-net-ldap'
    or title == 'systemd'
  |>
}
