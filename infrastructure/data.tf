data "onepassword_vault" "K8s" {
  name = "K8s"
}


# # Fetch existing datacenter by name
# data "ionoscloud_datacenter" "k8s-datacenter" {
#   name = "k8s-datacenter"
# }

# # Fetch existing public LAN
# data "ionoscloud_lan" "k8s-public-lan" {
#   datacenter_id = data.ionoscloud_datacenter.k8s-datacenter.id
#   name          = "public-lan"
# }

# # Fetch existing private LAN
# data "ionoscloud_lan" "k8s-private-lan" {
#   datacenter_id = data.ionoscloud_datacenter.k8s-datacenter.id
#   name          = "private-lan"
# }

# # Fetch existing IP block


# # Fetch an existing Kubernetes node pool called "application"
# data "ionoscloud_k8s_node_pool" "application" {
#   k8s_cluster_id = data.ionoscloud_k8s_cluster.cluster.id
#   name       = "ionos-k8s-application"
# }
