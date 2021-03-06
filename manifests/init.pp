class mesosdns(
  $zookeeper = '',
  $domain = 'mesos',
  $resolvers = '8.8.8.8',
  $version = '0.5.1'
) {
file { '/usr/local/mesos-dns':
  ensure => directory,
  mode => '755'
}
wget::fetch {'download_mesosdns':
  source => "https://github.com/mesosphere/mesos-dns/releases/download/v${version}/mesos-dns-v${version}-linux-amd64",
  destination => '/usr/local/mesos-dns/mesos-dns',
  timeout     => 60,
  verbose     => false,
  require     => File['/usr/local/mesos-dns']
}

file {'/usr/local/mesos-dns/mesos-dns':
  mode => '0755',
  ensure => present,
  require => Wget::Fetch['download_mesosdns']
}

  file { '/usr/local/mesos-dns/config.json':
    content => template('mesosdns/config.json.erb'),
  }
}
