####################################################
###                  OKE Cluster                 ###
####################################################
resource oci_containerengine_cluster k8s-cluster-demo-dev {
  depends_on = [ oci_core_instance.development-demo-bastion ]
  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }
  compartment_id = var.compartment_ocid

  endpoint_config {
    is_public_ip_enabled = "false"
    nsg_ids = [
    ]
    subnet_id = oci_core_subnet.oke-k8sApiEndpoint-subnet-development-demo-regional.id
  }
  image_policy_config {
    is_policy_enabled = "false"
  }
  kubernetes_version = var.oke_cluster_version
  name               = var.oke_cluster_name
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = "false"
      is_tiller_enabled               = "false"
    }
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    kubernetes_network_config {
      pods_cidr     = var.oke_pods_cidr
      services_cidr = var.oke_services_cidr
    }

    service_lb_subnet_ids = [
      oci_core_subnet.oke-svclbsubnet-development-demo-regional.id,
    ]
  }
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

##################################################
###                  OKE Pool                  ###
##################################################
resource oci_containerengine_node_pool k8s-cluster-demo-dev-pool {
  cluster_id     = oci_containerengine_cluster.k8s-cluster-demo-dev.id
  compartment_id = var.compartment_ocid
  initial_node_labels {
    key   = "name"
    value = var.oke_cluster_pool_name
  }
  kubernetes_version = data.oci_containerengine_node_pool_option.k8s-cluster-demo-dev-pool-option.kubernetes_versions[2]
  name               = var.oke_cluster_pool_name
  node_config_details {
    node_pool_pod_network_option_details {
      cni_type = "FLANNEL_OVERLAY"
    }
    nsg_ids = [
    ]
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.demo_availability_domains.availability_domains[0].name
      fault_domains = [
      ]
      subnet_id = oci_core_subnet.oke-nodesubnet-development-demo-regional.id
    }
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.demo_availability_domains.availability_domains[1].name
      fault_domains = [
      ]
      subnet_id = oci_core_subnet.oke-nodesubnet-development-demo-regional.id
    }
    placement_configs {
      availability_domain = data.oci_identity_availability_domains.demo_availability_domains.availability_domains[2].name
      fault_domains = [
      ]
      subnet_id = oci_core_subnet.oke-nodesubnet-development-demo-regional.id
    }
    size = var.oke_cluster_pool_size
  }
  node_eviction_node_pool_settings {
    eviction_grace_duration              = "PT1H"
    is_force_delete_after_grace_duration = "false"
  }
  node_metadata = {
  }
  node_shape = data.oci_containerengine_node_pool_option.k8s-cluster-demo-dev-pool-option.shapes[27]
  node_shape_config {
    memory_in_gbs = var.oke_cluster_pool_memory
    ocpus         = var.oke_cluster_pool_ocpu
  }
  node_source_details {
    image_id = data.oci_containerengine_node_pool_option.k8s-cluster-demo-dev-pool-option.sources[0].image_id
    source_type = data.oci_containerengine_node_pool_option.k8s-cluster-demo-dev-pool-option.sources[0].source_type
  }
}
