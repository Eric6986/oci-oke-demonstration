##################################################
###                   Bastion                  ###
##################################################
resource oci_core_instance development-demo-bastion {
  agent_config {
    are_all_plugins_disabled = "false"
    is_management_disabled   = "false"
    is_monitoring_disabled   = "false"
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }
  availability_domain = data.oci_identity_availability_domains.demo_availability_domains.availability_domains[0].name
  compartment_id = var.compartment_ocid
  create_vnic_details {
    assign_public_ip = "false"

    display_name = "development-demo-bastion"
    freeform_tags = {
    }
    hostname_label = "bastion"
    nsg_ids = [
    ]

    skip_source_dest_check = "false"
    subnet_id              = oci_core_subnet.oke-bastion-subnet-development-demo-regional.id
  }

  display_name = "development-demo-bastion"
  extended_metadata = {
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = "false"
  }
  launch_options {
    boot_volume_type                    = "PARAVIRTUALIZED"
    firmware                            = "UEFI_64"
    is_consistent_volume_naming_enabled = "true"
    network_type                        = "PARAVIRTUALIZED"
    remote_data_volume_type             = "PARAVIRTUALIZED"
  }

  shape = "VM.Standard.E4.Flex"
  shape_config {
    baseline_ocpu_utilization = "BASELINE_1_1"
    memory_in_gbs             = "1"
    ocpus                     = "1"
  }
  source_details {
    boot_volume_vpus_per_gb = "10"
    source_id   = data.oci_core_images.bastion_image.images[0].id
    source_type = "image"
  }
  state = "RUNNING"
}

###################################################
###                Bastion service              ###
###################################################
resource oci_bastion_bastion demo_bastion_service {
  depends_on = [ oci_core_instance.development-demo-bastion ]
  bastion_type     = "STANDARD"
  compartment_id   = var.compartment_ocid
  target_subnet_id = oci_core_subnet.oke-bastion-subnet-development-demo-regional.id
  client_cidr_block_allow_list = [
    var.bastion_local_laptop_ip
  ]
  name = "demo_bastion_service"
}

###################################################
###                Bastion session              ###
###################################################
resource oci_bastion_session demo_bastion_session {
  depends_on = [ oci_containerengine_cluster.k8s-cluster-demo-dev ]
  bastion_id = oci_bastion_bastion.demo_bastion_service.id
  key_details {
    public_key_content = file(var.bastion_ssh_public_key)
  }
  target_resource_details {
    session_type       = "MANAGED_SSH"
    target_resource_id = oci_core_instance.development-demo-bastion.id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = "22"
  }
  session_ttl_in_seconds = 3600
  display_name = "bastionsession-to-private-host"
}

###################################################
###            Bastion k8s api session          ###
###################################################
resource oci_bastion_session demo_k8s_api_bastion_session {
  depends_on = [ oci_containerengine_cluster.k8s-cluster-demo-dev ]
  bastion_id = oci_bastion_bastion.demo_bastion_service.id
  key_details {
    public_key_content = file(var.bastion_ssh_public_key)
  }
  target_resource_details {
    session_type                       = "PORT_FORWARDING"
    target_resource_private_ip_address = split(":", oci_containerengine_cluster.k8s-cluster-demo-dev.endpoints.0.private_endpoint)[0]
    target_resource_port               = split(":", oci_containerengine_cluster.k8s-cluster-demo-dev.endpoints.0.private_endpoint)[1]
  }
  session_ttl_in_seconds = 3600
  display_name = "bastionsession-to-private-k8s-api"
}
