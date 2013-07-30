class bind9::config {
  
  file { '/etc/bind':
    ensure    => directory,
    recurse   => true,
    purge     => false,
    source    => $bind9::configfilesfolder,
    notify => Service['bind9']
  }
  
  file { '/etc/bind/named.conf':
    ensure  => present,
    content => template('bind9/named.conf.erb'),
    mode    => '0644',
    require => [File['/etc/bind']],
    notify  => Service['bind9'],
  }

}