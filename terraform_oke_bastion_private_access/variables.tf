variable user_ocid {}
variable tenancy_ocid {}
variable compartment_ocid {}
variable fingerprint {}
variable private_key_path {}
variable region {}
variable bastion_ssh_public_key {}

##################################################
###                   Bastion                  ###
##################################################
variable bastion_image_shape { default = "VM.Standard.E4.Flex" }
variable bastion_operating_system { default = "Oracle Linux" }
variable bastion_operating_system_version { default = "7.9" }
variable default_tag { default = "DEMO" }

#################################################
###              Virtual Network              ###
#################################################
variable core_vcn_cidr_blocks { default = "192.168.0.0/16" }
variable core_vcn_name { default = "oke-vcn-development-demo" }
variable core_dns { default = "demo" }


#################################################
###                Sub Network                ###
#################################################
variable core_subnet_k8s_api_cidr { default = "192.168.0.0/28" }
variable core_subnet_k8s_api_name { default = "oke-k8sApiEndpoint-subnet-development-demo-regional" }
variable core_subnet_k8s_api_dns { default = "subk8sapi" }

variable core_subnet_node_cidr { default = "192.168.1.0/24" }
variable core_subnet_node_name { default = "oke-nodesubnet-development-demo-regional" }
variable core_subnet_node_dns { default = "subprivatenode" }

variable core_subnet_svclb_cidr { default = "192.168.2.0/24" }
variable core_subnet_svclb_name { default = "oke-svclbsubnet-development-demo-regional" }
variable core_subnet_svclb_dns { default = "subpublicnode" }

variable core_subnet_bastion_cidr { default = "192.168.3.0/28" }
variable core_subnet_bastion_name { default = "oke-bastion-subnet-development-demo-regional" }
variable core_subnet_bastion_dns { default = "subbastion" }

variable core_regional_service_network_name { default = "all-phx-services-in-oracle-services-network" }

variable core_route_private_name { default = "oke-private-routetable-development-demo" }
variable core_route_public_name { default = "oke-public-routetable-development-demo" }

variable core_network_block_type { default = "CIDR_BLOCK" }
variable core_network_serivce_block_type { default = "SERVICE_CIDR_BLOCK"}

##################################################
###                   Bastion                  ###
##################################################
variable bastion_local_laptop_ip { default = "0.0.0.0/0" }

####################################################
###                  OKE Cluster                 ###
####################################################
variable oke_cluster_name { default = "k8s-cluster-demo-dev"}
variable oke_cluster_version { default = "v1.23.4"}
variable oke_cluster_pool_name { default = "k8s-cluster-demo-dev-pool"}
variable oke_cluster_pool_size { default = "3"}
variable oke_cluster_pool_memory { default = "2"}
variable oke_cluster_pool_ocpu { default = "1"}
variable oke_pods_cidr { default = "10.100.0.0/16" }
variable oke_services_cidr { default = "10.200.0.0/16" }