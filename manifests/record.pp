define bind9::record($fqdn='', $target='', $type="A", $order=10) {
   
   notify{"Imma make concat puppet_bind_${fqdn}":}
   
   concat::fragment{"puppet_bind_${fqdn}":
      target  => "/var/lib/bind/puppet.office.zone",
      order   => $order,
      content => "${fqdn}   IN  ${type}   ${target}\n"
   }
   
}