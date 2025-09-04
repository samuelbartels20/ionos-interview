# resource "ionoscloud_mariadb_cluster" "k8s-mariadb-cluster" {
#   mariadb_version         = "10.6"
#   location                = ionoscloud_datacenter.k8s-datacenter.location
#   instances               = 1
#   cores                   = 1
#   ram                     = 4
#   storage_size            = 20
#   connections   {
#     datacenter_id         =  ionoscloud_datacenter.k8s-datacenter.id 
#     lan_id                =  ionoscloud_lan.k8s-private-lan.id 
#     cidr                  =  "10.0.0.0/24"
#   }
#   display_name            = "MariaDB_cluster"
#   maintenance_window {
#     day_of_the_week       = "Sunday"
#     time                  = "09:00:00"
#   }
#   credentials {
#     username              = module.onepassword_ionos.fields["MARIADB_USERNAME"]
#     password              = module.onepassword_ionos.fields["MARIADB_PASSWORD"]
#   }
# }

