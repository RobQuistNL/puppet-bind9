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
# are in the configfilesfolder bind9.
#
# [*VAR*]
#   DESC
#
# == Examples
# Configfilefolder: 'puppet:///prod-cluster/core/role/bind/bind_conf/'
#
# See README for details.
#
#
# == Author
#   Rob Quist | Enrise
#
class bind9 (
  $master       = true,
  $bool_monitor = false,
  $bindtype    = 'master',
  $monitor_tool = '',
  $namedconflocal,
  $zonefolder,
  $configfolder,
  $masterips,
  $slaveips,
  ) {

  $bool_master=any2bool($master)
  
  ### Managed resources
  package { 'bind9':
    ensure => $icinga::manage_package,
    name   => $icinga::package,
  }
  
  #include bind9::config
  
  class { 'bind9::config':
    bindtype => $bindtype,
    masterips => $masterips,
    slaveips => $slaveips
  }
  
  service { 'bind9':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['bind9::config']
  }
  
  ### Service monitoring, if enabled ( monitor => true )
  if $bind9::bool_monitor == true {
    monitor::port { "bind_named_53":
      protocol => 'tcp',
      port     => '53',
      target   => $::ipaddress,
      tool     => $bind9::monitor_tool,
      enable   => true,
    }
    monitor::port { "bind_named_953":
      protocol => 'tcp',
      port     => '953',
      target   => $::ipaddress,
      tool     => $bind9::monitor_tool,
      enable   => true,
    }
    monitor::process { 'named_process':
      process  => 'named',
      user     => 'bind',
      argument => '-u bind',
      tool     => $bind9::monitor_tool,
      enable   => true,
    }
  }
  
  Package[ 'bind9' ] -> Class[ 'bind9::config' ]
  Class[ 'bind9::config' ] -> Service[ 'bind9' ]
  
}
