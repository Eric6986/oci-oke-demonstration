#################################################
###              Virtual Network              ###
#################################################
resource oci_core_vcn oke-vcn-development-demo {
  cidr_blocks = [
    var.core_vcn_cidr_blocks
  ]
  compartment_id = var.compartment_ocid
  display_name = var.core_vcn_name
  dns_label    = var.core_dns
  freeform_tags = {
  }
  ipv6private_cidr_blocks = [
  ]
}

#################################################
###                Sub Network                ###
#################################################
resource oci_core_subnet oke-k8sApiEndpoint-subnet-development-demo-regional {
  cidr_block     = var.core_subnet_k8s_api_cidr
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke-vcn-development-demo.default_dhcp_options_id
  display_name    = var.core_subnet_k8s_api_name
  dns_label       = var.core_subnet_k8s_api_dns
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke-private-routetable-development-demo.id
  security_list_ids = [
    oci_core_security_list.oke-k8sApiEndpoint-development-demo.id,
  ]
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

resource oci_core_subnet oke-nodesubnet-development-demo-regional {
  cidr_block     = var.core_subnet_node_cidr
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke-vcn-development-demo.default_dhcp_options_id
  display_name    = var.core_subnet_node_name
  dns_label       = var.core_subnet_node_dns
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke-private-routetable-development-demo.id
  security_list_ids = [
    oci_core_security_list.oke-nodeseclist-development-demo.id,
  ]
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

resource oci_core_subnet oke-svclbsubnet-development-demo-regional {
  cidr_block     = var.core_subnet_svclb_cidr
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke-vcn-development-demo.default_dhcp_options_id
  display_name    = var.core_subnet_svclb_name
  dns_label       = var.core_subnet_svclb_dns
  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_vcn.oke-vcn-development-demo.default_route_table_id
  security_list_ids = [
    oci_core_vcn.oke-vcn-development-demo.default_security_list_id,
  ]
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

resource oci_core_subnet oke-bastion-subnet-development-demo-regional {
  cidr_block     = var.core_subnet_bastion_cidr
  compartment_id = var.compartment_ocid
  dhcp_options_id = oci_core_vcn.oke-vcn-development-demo.default_dhcp_options_id
  display_name    = var.core_subnet_bastion_name
  dns_label       = var.core_subnet_bastion_dns
  prohibit_internet_ingress  = "true"
  prohibit_public_ip_on_vnic = "true"
  route_table_id             = oci_core_route_table.oke-private-routetable-development-demo.id
  security_list_ids = [
    oci_core_security_list.oke-bastion-development-demo.id,
  ]
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

###################################################
###                 Route table                 ###
###################################################
resource oci_core_route_table oke-private-routetable-development-demo {
  compartment_id = var.compartment_ocid
  display_name = var.core_route_private_name
  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = var.core_network_block_type
    network_entity_id = oci_core_nat_gateway.oke-ngw-development-demo.id
  }
  route_rules {
    description       = "traffic to OCI services"
    destination       = var.core_regional_service_network_name
    destination_type  = var.core_network_serivce_block_type
    network_entity_id = oci_core_service_gateway.oke-sgw-development-demo.id
  }
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

# The default always for public
resource oci_core_default_route_table oke-public-routetable-development-demo {
  compartment_id = var.compartment_ocid
  display_name = var.core_route_public_name
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.oke-vcn-development-demo.default_route_table_id
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = var.core_network_block_type
    network_entity_id = oci_core_internet_gateway.oke-igw-development-demo.id
  }
}

##################################################
###              Internet gateway              ###
##################################################
resource oci_core_internet_gateway oke-igw-development-demo {
  compartment_id = var.compartment_ocid

  display_name = "oke-igw-development-demo"
  enabled      = "true"
  freeform_tags = {
  }
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

###################################################
###                Security list                ###
###################################################
resource oci_core_security_list oke-k8sApiEndpoint-development-demo {
  compartment_id = var.compartment_ocid

  display_name = "oke-k8sApiEndpoint-development-demo"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = var.core_regional_service_network_name
    destination_type = var.core_network_serivce_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = var.core_subnet_node_cidr
    destination_type = var.core_network_block_type
    protocol  = "6"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = var.core_subnet_node_cidr
    destination_type = var.core_network_block_type
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  ingress_security_rules {
    description = "Bastion server access to Kubernetes API endpoint"
    protocol    = "6"
    source      = var.core_subnet_bastion_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = var.core_subnet_node_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = var.core_subnet_node_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = var.core_subnet_node_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

resource oci_core_security_list oke-nodeseclist-development-demo {
  compartment_id = var.compartment_ocid

  display_name = "oke-nodeseclist-development-demo"
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = var.core_subnet_node_cidr
    destination_type = var.core_network_block_type
    protocol  = "all"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = var.core_subnet_k8s_api_cidr
    destination_type = var.core_network_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = var.core_subnet_k8s_api_cidr
    destination_type = var.core_network_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "12250"
      min = "12250"
    }
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = var.core_subnet_k8s_api_cidr
    destination_type = var.core_network_block_type
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = var.core_regional_service_network_name
    destination_type = var.core_network_serivce_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = var.core_network_block_type
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = var.core_network_block_type
    protocol  = "all"
    stateless = "false"
  }
  egress_security_rules {
    description = "Kubernetes service healthy check IP and port"
    destination      = var.core_subnet_node_cidr
    destination_type = var.core_network_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "10256"
      min = "10256"
    }
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = var.core_subnet_node_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = var.core_subnet_k8s_api_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = var.core_subnet_k8s_api_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Only allow access private service 80 http port. For API gateway or internal testing."
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  ingress_security_rules {
    description = "Kubernetes service healthy check IP and port"
    protocol    = "6"
    source      = var.core_subnet_node_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "10256"
      min = "10256"
    }
  }
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

# The default always for public
resource oci_core_default_security_list oke-svclbseclist-development-demo {
  depends_on = [oci_core_vcn.oke-vcn-development-demo]
  compartment_id = var.compartment_ocid

  display_name = "oke-svclbseclist-development-demo"
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "80"
      min = "80"
    }
  }
  ingress_security_rules {
    description = "API Gateway dynamic IP traffic in."
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "443"
      min = "443"
    }
  }
  manage_default_resource_id = oci_core_vcn.oke-vcn-development-demo.default_security_list_id
}

resource oci_core_security_list oke-bastion-development-demo {
  compartment_id = var.compartment_ocid

  display_name = "oke-bastion-development-demo"

  egress_security_rules {
    description      = "SSH outbound"
    destination      = var.core_subnet_bastion_cidr
    destination_type = var.core_network_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  egress_security_rules {
    description      = "Bastion server to Kubernetes API endpoint communication"
    destination      = var.core_subnet_k8s_api_cidr
    destination_type = var.core_network_block_type
    protocol  = "6"
    stateless = "false"
    tcp_options {
      max = "6443"
      min = "6443"
    }
  }

  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = var.core_regional_service_network_name
    destination_type = var.core_network_serivce_block_type
    protocol         = "6"
    stateless        = false

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  ingress_security_rules {
    description = "SSH inbound"
    protocol    = "6"
    source      = var.core_subnet_bastion_cidr
    source_type = var.core_network_block_type
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}

###################################################
###                 Default DHCP                ###
###################################################
resource oci_core_default_dhcp_options Default-DHCP-Options-for-oke-vcn-development-demo {
  compartment_id = var.compartment_ocid

  display_name     = "Default DHCP Options for oke-vcn-development-demo"
  domain_name_type = "CUSTOM_DOMAIN"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.oke-vcn-development-demo.default_dhcp_options_id
  options {
    custom_dns_servers = [
    ]
    server_type = "VcnLocalPlusInternet"
    type        = "DomainNameServer"
  }
  options {
    search_domain_names = [
      "developmentdev.oraclevcn.com",
    ]
    type = "SearchDomain"
  }
}

###################################################
###                 NAT Gateway                 ###
###################################################
resource oci_core_nat_gateway oke-ngw-development-demo {
  block_traffic  = "false"
  compartment_id = var.compartment_ocid

  display_name = "oke-ngw-development-demo"
  freeform_tags = {
  }
  vcn_id       = oci_core_vcn.oke-vcn-development-demo.id
}

##################################################
###               Service Gateway              ###
##################################################
resource oci_core_service_gateway oke-sgw-development-demo {
  compartment_id = var.compartment_ocid

  display_name = "oke-sgw-development-demo"
  freeform_tags = {
  }
  services {
    service_id = data.oci_core_services.oci_services.services[0].id
  }
  vcn_id = oci_core_vcn.oke-vcn-development-demo.id
}
