class docker::nextcloud {
  include ::bootserver_authorized_keys
  include ::docker::postgres
  include ::puavo_conf

  file {
    '/etc/puavo-docker/files/configure-nextcloud':
      mode   => '0755',
      source => 'puppet:///modules/docker/configure-nextcloud';

    '/etc/puavo-docker/files/run-nextcloud':
      mode    => '0755',
      require => File['/etc/puavo-docker/files/configure-nextcloud'],
      source  => 'puppet:///modules/docker/run-nextcloud';

    '/etc/puavo-docker/files/setup-nextcloud-docker':
      mode   => '0755',
      source => 'puppet:///modules/docker/setup-nextcloud-docker';

    '/etc/puavo-docker/files/Dockerfile.nextcloud':
      require => [ File['/etc/puavo-docker/files/run-nextcloud']
                 , File['/etc/puavo-docker/files/setup-nextcloud-docker'] ],
      source  => 'puppet:///modules/docker/Dockerfile.nextcloud';

    '/usr/local/sbin/puavo-update-letsencrypt-certificates':
      mode   => '0755',
      source => 'puppet:///modules/docker/puavo-update-letsencrypt-certificates';
  }

  ::puavo_conf::definition {
    'puavo-docker-nextcloud.json':
      source => 'puppet:///modules/docker/puavo-docker-nextcloud.json';

    'puavo-nextcloud.json':
      source => 'puppet:///modules/docker/puavo-nextcloud.json';
  }
}
