class mesosdns(
  $zookeeper = '',
  $domain = '',
  $resolvers = '', 
  $marathonurl = '',
  $mesosdnshost = '',
) {
  package { 'git-core':
    ensure => installed,
  }

  exec { 'mesos-dns':
    path    => ['/usr/bin', '/usr/sbin', '/bin', '/usr/local/go/bin', '/root/go/bin'],
    environment => ["GOROOT=/usr/local/go","GOPATH=/root/go"],
    command => 'wget https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz -P /tmp && tar zxf /tmp/go1.4.linux-amd64.tar.gz -C /usr/local/ && go get github.com/tools/godep && go get github.com/mesosphere/mesos-dns && cd $GOPATH/src/github.com/mesosphere/mesos-dns && make all && mkdir /usr/local/mesos-dns && mv mesos-dns /usr/local/mesos-dns',
    require => Package['git-core'],
    unless => 'ls /usr/local/mesos-dns/mesos-dns',
  }

  file { '/usr/local/mesos-dns/config.json':
    content => template('mesosdns/config.json.erb'),
  }

  file { '/usr/local/mesos-dns/mesos-dns.json':
    content => template('mesosdns/mesos-dns.json.erb'),
    require => [Exec['mesos-dns'], File['/usr/local/mesos-dns/config.json']],
    notify => Exec['mesos-dns submit'],
  }

  exec { 'mesos-dns submit':
    command => "curl -X POST -H 'Content-Type: application/json' http://${marathonurl}/v2/apps -d@/usr/local/mesos-dns/mesos-dns.json",
    refreshonly => true,
  }
}

