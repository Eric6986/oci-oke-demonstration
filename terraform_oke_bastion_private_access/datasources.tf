data oci_identity_availability_domains demo_availability_domains {
    #Required
    compartment_id = var.compartment_ocid
}

data oci_containerengine_node_pool_option k8s-cluster-demo-dev-pool-option {
    #Required
    node_pool_option_id = oci_containerengine_cluster.k8s-cluster-demo-dev.id

    #Optional
    compartment_id = var.compartment_ocid
}

data oci_bastion_session local_k8s_port_forward_session {
    #Required
    session_id = oci_bastion_session.demo_k8s_api_bastion_session.id
}

data oci_core_images bastion_image {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    operating_system = var.bastion_operating_system
    operating_system_version = var.bastion_operating_system_version
    shape = var.bastion_image_shape
}

data oci_core_services oci_services {
}