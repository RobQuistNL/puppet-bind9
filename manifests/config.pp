class bind9::config (
  $bindtype    = 'notset',
  $slaveips,
  $masterips,
  ){
  
  if ($bindtype == 'master') {
    
    $masterslavetext = "allow-update { key \"DDNS_DHCP\"; ${slaveips} };
    allow-transfer { ${slaveips} };
    also-notify { ${slaveips} };
    notify yes;"

	  file { '/var/lib/bind':
	    ensure    => directory,
	    recurse   => true,
	    purge     => false,
	    owner   => 'bind',
	    group   => 'bind',
	    source    => $bind9::zonefolder,
	  }
  } else { #Create the folders but don't fill them yet
    $masterslavetext = "masters { ${masterips} };"

    file { '/var/lib/bind':
      ensure    => directory,
      owner   => 'bind',
      group   => 'bind',
    }
    
    file { '/var/lib/bind/common':
      ensure    => directory,
      owner   => 'bind',
      group   => 'bind',
    }
    
    file { '/var/lib/bind/internal':
      ensure    => directory,
      owner   => 'bind',
      group   => 'bind',
    }
    
    File ['/var/lib/bind'] -> File['/var/lib/bind/common']
    File ['/var/lib/bind/common'] -> File['/var/lib/bind/internal']
    
  }

  file { '/etc/bind':
      ensure    => directory,
      recurse   => true,
      purge     => false,
      owner   => 'bind',
      group   => 'bind',
      source    => $bind9::configfolder,
      notify => Service['bind9']
  }
  notify{"named.conf":}
  file { '/etc/bind/named.conf':
    ensure  => present,
    content => template('bind9/named.conf.erb'),
    mode    => '0644',
    owner   => 'bind',
    group   => 'bind',
    require => File['/etc/bind'],
    notify  => Service['bind9'],
  }
  notify{"named.conf.local":}
  file { '/etc/bind/named.conf.local':
    ensure  => present,
    content => template($bind9::namedconflocal),
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