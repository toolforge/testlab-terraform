# T333874
#resource "openstack_containerinfra_cluster_v1" "k8s_123" {
#  name                = "paws-123"
#  cluster_template_id = resource.openstack_containerinfra_clustertemplate_v1.template_123.id
#  master_count        = 1
#  node_count          = 1
#}

resource "openstack_containerinfra_clustertemplate_v1" "template_123" {
  name                  = "testlabs-123"
  coe                   = "kubernetes"
  dns_nameserver        = "8.8.8.8"
  docker_storage_driver = "overlay2"
  docker_volume_size    = "20"
  external_network_id   = "${var.external_network_id[var.datacenter]}"
  fixed_subnet          = "${var.fixed_subnet[var.datacenter]}"
  fixed_network         = "${var.fixed_network[var.datacenter]}"
  flavor                = "${var.worker_flavor[var.datacenter]}"
  floating_ip_enabled   = "false"
  image                 = "${var.image_name[var.datacenter]}"
  master_flavor         = "${var.control_flavor[var.datacenter]}"
  network_driver        = "flannel"

  labels = {
    kube_tag               = "v1.23.15-rancher1-linux-amd64"
    hyperkube_prefix       = "docker.io/rancher/"
    cloud_provider_enabled = "true"
  }
}

resource "openstack_db_instance_v1" "db_123" {
  region    = "${var.region[var.datacenter]}"
  name      = "testlabs-123"
  flavor_id = "${var.db_flavor_uuid[var.datacenter]}"
  size      = "${var.db_size[var.datacenter]}"

  network {
    uuid = "${var.network_uuid[var.datacenter]}"
  }

  user {
    name      = "testlabs-123"
    host      = "%"
    password  = "notapassword"
    databases = ["testlabs-123"]
  }

  database {
    name     = "testlabs-123"
  }

  datastore {
    version = "5.7.29"
    type    = "mysql"
  }
}

resource "openstack_compute_instance_v2" "vm" {
  name            = "testlabs-tf"
  image_id        = data.openstack_images_image_v2.debian.id
  flavor_id       = "bb8bee7e-d8f9-460b-8344-74f745c139b9" # update to lookup?

  network {
    name = "${var.fixed_subnet[var.datacenter]}"
  }
}

resource "openstack_blockstorage_volume_v3" "volume" {
  region      = "${var.region[var.datacenter]}"
  name        = "volume_tf"
  description = "test volume deployed with terraform"
  size        = 3
}


resource "openstack_compute_secgroup_v2" "secgroup" {
  name        = "terraform-test"
  description = "security group deployed by terraform"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "127.0.0.1/32"
  }

}