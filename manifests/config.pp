# Bind9 configuration
#
# [slaveips]
#   semicolon-seperated list of slave IP's that are allowed to connect
#     Example: 192.168.0.1; 192.168.2.25;
# [masterips]
#   semicolon-seperated list of master IP's that are allowed to push
#   and where should be pulled from
#     Example: 192.168.0.4;
# [bindtype]
#  String - 'master' or 'slave'
#   Sets the type of the bind9 service. In case of slave, the 
#   zone files are not copied. 

class bind9::config (
  $bindtype,
  $slaveips,
  $masterips,
  ){
  
  include concat::setup
  
  # Create all the needed folders
  file { $bind9::zonelibrary:
    ensure => directory,
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
  }
  
  file { "${bind9::zonelibrary}/zones":
    ensure => directory,
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
  }
  
  file { "${bind9::zonelibrary}/zones/rev":
    ensure => directory,
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
  }
  
  File [$bind9::zonelibrary] -> File["${bind9::zonelibrary}/zones"]
  File ["${bind9::zonelibrary}/zones"] -> File["${bind9::zonelibrary}/zones/rev"]
  
  # Now for master / slave specific code
  if ($bindtype == 'master') {
    
    $masterslavetext = "allow-update { key \"DDNS_DHCP\"; ${slaveips} };
    allow-transfer { ${slaveips} };
    also-notify { ${slaveips} };
    notify yes;"
	  
	  $puppetzone = "${bind9::zonelibrary}/${bind9::puppetzonefile}"
	
	  concat{$bind9::puppetzonefile:
      owner => $bind9::config_file_owner,
      group => $bind9::config_file_group,
      mode  => $bind9::config_file_mode,
    }
    
    concat::fragment { 'puppet_header':
      target  => $bind9::puppetzonefile,
      content => $bind9::puppetzoneheader,
      order   => 01,
    }
    
    Bind9::Record <<||>>
	  
  } else {
    $masterslavetext = "masters { ${masterips} };"
  }
  
  # Make all the configuration
  file { $bind9::config_dir:
      ensure    => directory,
      recurse   => true,
      purge     => false,
      owner  => $bind9::config_file_owner,
      group  => $bind9::config_file_group,
      notify => Service['bind9']
  }

  file { "${bind9::config_dir}/named.conf":
    ensure  => present,
    content => template('bind9/named.conf.erb'),
    mode    => '0644',
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
    require => File[$bind9::config_dir],
    notify  => Service[$bind9::service],
  }

  file { "${bind9::config_dir}/named.conf.local":
    ensure  => present,
    content => template($bind9::namedconflocal),
    mode    => '0644',
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
    require => File[$bind9::config_dir],
    notify  => Service[$bind9::service],
  }
  
  file { "${bind9::config_dir}/named.conf.options":
    ensure  => present,
    content => template($bind9::namedconfoptions),
    mode    => '0644',
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
    require => File[$bind9::config_dir],
    notify  => Service[$bind9::service],
  }
  
  file { "${bind9::config_dir}/rndc.key":
    ensure  => present,
    content => template($bind9::rndckey),
    mode    => '0644',
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
    require => File[$bind9::config_dir],
    notify  => Service[$bind9::service],
  }
  
  file { '/var/log/named':
    ensure    => directory,
    mode    => '0755',
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
    require => Package[$bind9::service],
  }
  
  file { '/var/log/named/bind-updates.log':
    ensure  => file,
    mode    => '0755',
    owner  => $bind9::config_file_owner,
    group  => $bind9::config_file_group,
    require => File['/var/log/named'],
    notify  => Service[$bind9::service],
  }
  
}