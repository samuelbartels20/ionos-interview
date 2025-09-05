resource "ionoscloud_application_loadbalancer" "loadbalancer" {
  datacenter_id         = ionoscloud_datacenter.k8s-datacenter.id
  name                  = "loadbalancer"
  listener_lan          = ionoscloud_lan.k8s-public-lan.id
  ips                   = [ "85.215.72.158","217.168.177.121","212.227.224.234"]
  target_lan            = ionoscloud_lan.k8s-private-lan.id
  lb_private_ips        = [ "10.13.72.225/24"]
  central_logging       = true
  logging_format        = "%%{+Q}o %%{-Q}ci - - [%trg] %r %ST %B \"\" \"\" %cp %ms %ft %b %s %TR %Tw %Tc %Tr %Ta %tsc %ac %fc %bc %sc %rc %sq %bq %CC %CS %hrl %hsl"
}

