class bind9::config {
  
  file { '/etc/bind':
    ensure    => directory,
    recurse   => true,
    purge     => false,
    owner   => 'bind',
    group   => 'bind',
    source    => $bind9::configfilesfolder,
    notify => Service['bind9']
  }
  
  file { '/etc/bind/named.conf':
    ensure  => present,
    content => template('bind9/named.conf.erb'),
    mode    => '0644',
    owner   => 'bind',
    group   => 'bind',
    require => File['/etc/bind'],
    notify  => Service['bind9'],
  }
  
  file { '/var/log/named':
    ensure    => directory,
    mode    => '0755',
    owner   => 'bind',
    group   => 'bind',
    require => Package['bind9'],
  }
  
  file { '/var/log/named/bind-updates.log':
    ensure  => file,
    mode    => '0755',
    owner   => 'bind',
    group   => 'bind',
    require => File['/var/log/named'],
    notify  => Service['bind9'],
  }
  
  
  
}