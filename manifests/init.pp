# = Class: bind9
#
# This is the main bind9 class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# Make sure /etc/bind/named.conf.options and /etc/bind/named.conf.local
# are in the $configfolder bind9.
#
# [*VAR*]
#   DESC
#
# == Examples
# $bool_monitor: true #Monitoring is on (port 53 and the service)
# $bindtype: 'slave' #setup this machine as a slave server
# $namedconflocal: local named configuration
# $configfolder: 'puppet:///prod-cluster/core/role/nameserver/bind_conf/'
# $zonefolder: 'puppet:///prod-cluster/core/role/nameserver/bind_conf/'
# $masterips: '192.168.1.1;'
# $slaveips: '192.168.3.14;192.168.3.15;'
# $puppetzoneheadertemplate: The prefix for the automated shared resources file. e.g.: template('example.com.zone')
#
# See README for details.
#
#
# == Author
#   Rob Quist | Enrise
#
class bind9 (
  $bool_monitor = false,
  $bindtype    = 'master',
  $monitor_tool = params_lookup( 'monitor_tool' , 'global' ),
  $namedconflocal,
  $namedconfoptions,
  $rndckey,
  $zonefolder,
  $configfolder,
  $masterips,
  $slaveips,
  $puppetzoneheader,
  $puppetzonefile,
  ) inherits bind9::params {
  
  # Variables defined in standard::params
  $package=$bind9::params::package
  $service=$bind9::params::service
  $config_dir=$bind9::params::config_dir
  $config_file_mode=$bind9::params::config_file_mode
  $config_file_owner=$bind9::params::config_file_owner
  $config_file_group=$bind9::params::config_file_group
  $dns_port=$bind9::params::dns_port
  $dns_protocol=$bind9::params::dns_protocol
  $process=$bind9::params::process
  $process_pidfile=$bind9::params::process_pidfile
  $zonelibrary=$bind9::params::zonelibrary
  
  ### Managed resources
  package { $package:
    ensure => $icinga::manage_package,
    name   => $icinga::package,
  }
  
  #include bind9::config
  
  class { 'bind9::config':
    bindtype => $bindtype,
    masterips => $masterips,
    slaveips => $slaveips
  }
  
  service { $service:
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['bind9::config']
  }
  
  ### Service monitoring, if enabled ( monitor => true )
  if $bind9::bool_monitor == true {
    monitor::port { 'bind_named_53':
      protocol => $dns_protocol,
      port     => $dns_port,
      target   => $::ipaddress,
      tool     => $bind9::monitor_tool,
      enable   => true,
    }
    monitor::process { 'named_process':
      process  => $process,
      user     => $config_file_owner,
      argument => "-u ${config_file_owner}",
      pidfile  => $process_pidfile,
      service  => $service,
      tool     => $bind9::monitor_tool,
      enable   => true,
    }
  }
  
  Package[ 'bind9' ] -> Class[ 'bind9::config' ]
  Class[ 'bind9::config' ] -> Service[ 'bind9' ]
  
}
