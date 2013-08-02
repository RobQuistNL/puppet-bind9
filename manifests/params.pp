# Class: bind9::params
#
# This class defines default parameters used by the main module class standard
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to standard class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class bind9::params {

  ### Application related parameters
  $package = $::operatingsystem ? {
    default => 'bind9',
  }

  $service = $::operatingsystem ? {
    default => 'bind9',
  }
  
  $process = $::operatingsystem ? {
    default => 'named',
  }
  
  $process_pidfile = $::operatingsystem ? {
    default => '/etc/named.pid',
  }

  $config_dir = $::operatingsystem ? {
    default => '/etc/bind',
  }
  
  $zonelibrary = $::operatingsystem ? {
    default => '/var/lib/bind',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/bind/standard.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'bind',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'bind',
  }
  
  $dns_port = $::operatingsystem ? {
    default => '53',
  }
  
  $dns_protocol = $::operatingsystem ? {
    default => 'tcp',
  }

}