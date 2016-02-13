class mesosdns(
  $zookeeper = '',
  $domain = 'mesos',
  $resolvers = '8.8.8.8', 
  $marathonurl = '',
  $mesosdnshost = '',
  $version = '0.5.1'
) {
  package { 'git-core':
    ensure => installed,
  }
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

  file { '/usr/local/mesos-dns/mesos-dns.json':
    content => template('mesosdns/mesos-dns.json.erb'),
    require => [File['/usr/local/mesos-dns/mesos-dns'], File['/usr/local/mesos-dns/config.json']],
  }
 # TODO: Replace executing curl with proper marathon task resource
  exec { 'mesos-dns submit':
    command => "/usr/bin/curl -X POST -H 'Content-Type: application/json' http://${marathonurl}/v2/apps -d@/usr/local/mesos-dns/mesos-dns.json && /usr/bin/touch /tmp/marathonok",
    unless => '/bin/ls /tmp/marathonok',
  }
}

