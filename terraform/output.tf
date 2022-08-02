####################################################
###                 Output command               ###
####################################################
output "local_oke_setting_command" {
  value = "oci ce cluster create-kubeconfig --cluster-id ${oci_containerengine_cluster.k8s-cluster-demo-dev.id} --file $HOME/.kube/config --region ${var.region} --token-version 2.0.0 && sed -i '' 's/${split(":", oci_containerengine_cluster.k8s-cluster-demo-dev.endpoints.0.private_endpoint)[0]}/127.0.0.1/' $HOME/.kube/config"
}

output "local_oke_port_forward" {
  value = "${data.oci_bastion_session.local_k8s_port_forward_session.ssh_metadata.command} &"
}

output "local_connection_to_bastion_command" {
  value = oci_bastion_session.demo_bastion_session.ssh_metadata.command
}