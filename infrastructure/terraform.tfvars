datacenter_name     = "k8s-production"
datacenter_location = "de/fra"

ipblock_size        = 1

# app_nodepool_min_nodes    = 1
# app_nodepool_max_nodes    = 3
app_nodepool_node_count   = 3
app_nodepool_cpu_family   = "INTEL_SKYLAKE"
app_nodepool_cores        = 4
app_nodepool_ram          = 20480
app_nodepool_storage_size = 100

cluster_name          = "ionos-k8s"
kubernetes_version    = "1.32.6"
maintenance_day       = "Sunday"
maintenance_time      = "10:00:00"
api_subnet_allow_list = ["154.161.97.168/32"]

region = "us-east-1"

