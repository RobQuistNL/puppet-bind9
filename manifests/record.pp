define bind9::record($fqdn='', $target='', $type='A', $order=10) {
   
   concat::fragment{"puppet_bind_${fqdn}":
      target  => '/var/lib/bind/puppet.office.zone',
      order   => $order,
      content => "${fqdn}   IN  ${type}   ${target}\n"
   }
   
}