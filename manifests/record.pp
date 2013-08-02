define bind9::record($fqdn='', $target='', $type='A', $order=10) {
   
   concat::fragment{"puppet_bind_${fqdn}":
      target  => $bind9::puppetzonefile,
      order   => $order,
      content => "${fqdn}   IN  ${type}   ${target}\n"
   }
   
}