# Use Terraform to create high available network environment for OKE (Oracle Kubernetes Engine)

## Project description

Include the TerraForm script, shell script to create high available network environment on OCI. I seperate some sections to descript this resource, and will invoke the GitHub action CI/CD flow later. 

## How to use code 

### STEP 1

Clone the repo from github by executing the command as follows and then go to terraform-oci-oke directory:

```
[~] git clone https://github.com/Eric6986/oci-oke-demonstration.git
[~] cd terraform_oke_bastion_private_access/
[~/terraform_oke_bastion_private_access] ls -lt
-rw-r--r--  1 erichsieh  staff   3398 Aug  2 01:40 containerengine.tf
-rw-r--r--  1 erichsieh  staff   3142 Aug  2 01:36 variables.tf
-rw-r--r--  1 erichsieh  staff  15253 Aug  2 01:31 network.tf
-rw-r--r--  1 erichsieh  staff   2525 Aug  1 21:54 tf_vars_setting.sh
-rw-r--r--  1 erichsieh  staff   3930 Jul 29 19:22 bastion.tf
-rw-r--r--  1 erichsieh  staff    805 Jul 29 19:01 datasources.tf
-rw-r--r--  1 erichsieh  staff    192 Jul 29 01:01 provider.tf
-rw-r--r--  1 erichsieh  staff    777 Jul 29 01:00 output.tf

```

### STEP 2

Install OCI CLI tools from https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

```
[~/terraform_oke_bastion_private_access] oci -version
3.9.0
```

### STEP 3

Download your private PEM key from OCI console, past the content in $HOME/.oci/config.

```
[~/terraform_oke_bastion_private_access] vim $HOME/.oci/config
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa6ldciwat(..................)dtwwa2guxbwvq
fingerprint=1a:5b:(..................):c7:87
tenancy=ocid1.tenancy.oc1..aaaaaaaakatveh(..................)c6gwlw52nvtq
region=us-phoenix-1
key_file=<path to your private keyfile> # TODO
```

You may see the warning message like below, then you can use the *oci setup repair-file-permissions --file $HOME/.oci/config* to modify the config file permission.
```
WARNING: Permissions on $HOME/.oci/config are too open.
To fix this please try executing the following command:
oci setup repair-file-permissions --file $HOME/.oci/config
```

### STEP 4

Prepare your ssh key for bastion service. The default pairing key put in $HOME/.ssh/id_rsa.pub.
```
[~/terraform_oke_bastion_private_access] ssh-keygen -t rsa -b 4096
Generating public/private rsa key pair.
Enter file in which to save the key ($HOME/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in $HOME/.ssh/id_rsa
Your public key has been saved in $HOME/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:
The key's randomart image is:
```

### STEP 5

Download the latest terraform from https://www.terraform.io/downloads.html. The MacOS can use brew install Terraform also. Refer the installation step from https://formulae.brew.sh/formula/terraform. 

```
[~/terraform_oke_bastion_private_access] terraform -version
Terraform v1.2.6
```

### STEP 6.

Run *source tf_vars_setting.sh* to setup terraform environment variable. You also can use -h to review the parameter detail.

```
[~/terraform_oke_bastion_private_access] source tf_vars_setting.sh
TF_VAR_user_ocid=ocid1.user.oc1..aaaaaaaa6ldciwat(..................)dtwwa2guxbwvq
TF_VAR_fingerprint=1a:5b:(..................):c7:87
TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaakatveh(..................)c6gwlw52nvtq
TF_VAR_region=us-phoenix-1
TF_VAR_private_key_path=$HOME/.oci/oci_api_key.pem
TF_VAR_compartment_ocid=ocid1.tenancy.oc1..aaaaaaaakatveh(..................)c6gwlw52nvtq
TF_VAR_bastion_ssh_public_key=$HOME/.ssh/id_rsa.pub
```

### STEP 7

Run *terraform init* to download the lastest neccesary providers:

```
[~/terraform_oke_bastion_private_access] terraform init -upgrade
Initializing the backend...

Initializing provider plugins...
- Finding oracle/oci versions matching ">= 4.0.0"...
- Installing oracle/oci v4.86.1...
- Installed oracle/oci v4.86.1 (signed by a HashiCorp partner, key ID 1533A49284137CEB)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### STEP 8
Run *terraform apply* to provision the content of this repo (type **yes** to confirm the the apply phase):

```
[~/terraform_oke_bastion_private_access] terraform apply
data.oci_identity_availability_domains.demo_availability_domains: Reading...
data.oci_core_images.bastion_image: Reading...
data.oci_core_services.oci_services: Reading...
data.oci_identity_availability_domains.demo_availability_domains: Read complete after 2s [id=IdentityAvailabilityDomainsDataSource-1303532918]
data.oci_core_images.bastion_image: Read complete after 2s [id=CoreImagesDataSource-4227770484]
data.oci_core_services.oci_services: Read complete after 2s [id=CoreServicesDataSource-0]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

(...)

Plan: 21 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + local_connection_to_bastion_command = (known after apply)
  + local_oke_port_forward              = (known after apply)
  + local_oke_setting_command           = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

(...)

oci_containerengine_node_pool.k8s-cluster-demo-dev-pool: Still creating... [2m20s elapsed]
oci_containerengine_node_pool.k8s-cluster-demo-dev-pool: Still creating... [2m30s elapsed]
oci_containerengine_node_pool.k8s-cluster-demo-dev-pool: Creation complete after 2m35s [id=ocid1.nodepool.oc1.phx.aaaaaaaa36gvspyxpyhjjzwl6vbdfxlusfnen4an5a32vhmdknzsgh2kwqca]

Apply complete! Resources: 21 added, 0 changed, 0 destroyed.

Outputs:

local_connection_to_bastion_command = "ssh -i <privateKey> -o ProxyCommand=\"ssh -i <privateKey> -W %h:%p -p 22 ocid1.bastionsession.oc1.phx.amaaaaaahxv2vbyab(.........)4h6q@host.bastion.us-phoenix-1.oci.oraclecloud.com\" -p 22 opc@192.168.3.3"
local_oke_port_forward = "ssh -i <privateKey> -N -L <localPort>:192.168.0.3:6443 -p 22 ocid1.bastionsession.oc1.phx.amaaaaaahxv2vb(.........)jzona@host.bastion.us-phoenix-1.oci.oraclecloud.com &"
local_oke_setting_command = "oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.phx.aaaaaaaahq5u4iaixzf(.........)yqya --file $HOME/.kube/config --region us-phoenix-1 --token-version 2.0.0 && sed -i '' 's/192.168.0.3/127.0.0.1/' $HOME/.kube/config"
```


### STEP 9
Use the output command to testing your local connection with Bastion server, kubectl command loacl access.

Create the managed SSH session from local to bastion server.
```
[~/terraform_oke_bastion_private_access] ssh -i $HOME/.ssh/id_rsa -o ProxyCommand="ssh -i $HOME/.ssh/id_rsa -W %h:%p -p 22 ocid1.bastionsession.oc1.phx.amaaaaaahxv2vbyab(.........)4h6q@host.bastion.us-phoenix-1.oci.oraclecloud.com" -p 22 opc@192.168.3.3

The authenticity of host '192.168.3.3 (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.3.3' (ED25519) to the list of known hosts.
-bash: warning: setlocale: LC_CTYPE: cannot change locale (UTF-8): No such file or directory
[opc@bastion ~]$
```

Setup the the local kubenetes configuration. The config file will add the private cluster setting in $HOME/.kube/config. Since we have to modify the kubernetes API endpoint from internal IP (192.168.0.3) to localhost (127.0.0.1), so we use sed command to update it.
```
[~/terraform_oke_bastion_private_access] oci ce cluster create-kubeconfig --cluster-id ocid1.cluster.oc1.phx.aaaaaaaahq5u4iaixzf(.........)yqya --file $HOME/.kube/config --region us-phoenix-1 --token-version 2.0.0 && sed -i '' 's/192.168.0.3/127.0.0.1/' $HOME/.kube/config

Existing Kubeconfig file found at $HOME/.kube/config and new config merged into it
```

Create a port forwarding tunnel on local device. Then you can use the *kubectl* or k8s client tools (ex: k9s) to access the cluster.
```
[~/terraform_oke_bastion_private_access] ssh -i $HOME/.ssh/id_rsa -N -L 6443:192.168.0.3:6443 -p 22 ocid1.bastionsession.oc1.phx.amaaaaaahxv2vb(.........)jzona@host.bastion.us-phoenix-1.oci.oraclecloud.com &

[1] 20741

[~/terraform_oke_bastion_private_access] kubectl get ns
NAME              STATUS   AGE
default           Active   24m
kube-node-lease   Active   24m
kube-public       Active   24m
kube-system       Active   24m
```

### STEP 10
After testing the environment you can remove the OCI OKE infra. You should just run *terraform destroy* (type **yes** for confirmation of the destroy phase):

```
[~/terraform_oke_bastion_private_access] terraform destroy

data.oci_core_services.oci_services: Reading...
data.oci_identity_availability_domains.demo_availability_domains: Reading...
data.oci_core_images.bastion_image: Reading...

(...)

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # oci_bastion_bastion.demo_bastion_service will be destroyed

(...)

Plan: 0 to add, 0 to change, 21 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

(...)

oci_core_security_list.oke-bastion-development-demo: Destruction complete after 2s
oci_core_nat_gateway.oke-ngw-development-demo: Destruction complete after 2s
oci_core_service_gateway.oke-sgw-development-demo: Destruction complete after 6s
oci_core_vcn.oke-vcn-development-demo: Destroying... [id=ocid1.vcn.oc1.phx.amaaaaaahxv(.........)tlcq]
oci_core_vcn.oke-vcn-development-demo: Destruction complete after 2s

Destroy complete! Resources: 21 destroyed.

```
