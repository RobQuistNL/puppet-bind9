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
  $configfilesfolder,
  ) {

  $bool_master=any2bool($master)
  
  ### Managed resources
  package { 'bind9':
    ensure => $icinga::manage_package,
    name   => $icinga::package,
  }
  
  include bind9::config
  
  service { 'bind9':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['bind9::config']
  }
  
}
