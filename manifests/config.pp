class bind9::config {
  
  file { '/etc/bind':
    ensure => directory,
    mode   => '0755',
  }
  
  file { '/etc/bind/named.conf':
    ensure  => present,
    content => template('bind9/named.conf.erb'),
    mode    => '0644',
    require => [File['/etc/bind']],
    notify  => Service['bind9'],
  }

}