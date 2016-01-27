resource "google_compute_instance" "edge-nodes" {
  name = "${var.name}-edge-${format("%03d", count.index+1)}"
  description = "${var.name} edge node #${format("%03d", count.index+1)}"
  machine_type = "${var.edge_type}"
  zone = "${var.zone}"
  can_ip_forward = false
  tags = ["${var.name}", "edge"]

  disk {
    image = "centos-7-v20150526"
    size = "${var.edge_volume_size}"
    auto_delete = true
  }

  network_interface {
    network = "${google_compute_network.network.name}"
    access_config {}
  }

  metadata {
    role = "edge"
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
    ssh_user = "${var.ssh_user}"
  }

  metadata_startup_script = "${file("boot.sh")}"

  count = "${var.edge_count}"
}

resource "null_resource" "bootstrap-edge" {
  count = "${var.edge_count}"

  depends_on = ["google_compute_instance.edge-nodes", "null_resource.bootstrap-leader"]
  triggers {
    cluster_instance_ips = "${join(",", google_compute_instance.leader-nodes.*.network_interface.0.address)}"
  }

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
    host = "${element(google_compute_instance.edge-nodes.*.network_interface.0.access_config.0.nat_ip, count.index)}"
  }

  # set up metadata
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/mantl/cloud-init-completed ]; do echo waiting for cloud-init; sleep 5; done",
      "echo ${base64encode(element(google_compute_instance.edge-nodes.*.id, count.index))} | base64 -d | sudo tee /etc/mantl/id > /dev/null",
      "echo ${base64encode(element(google_compute_instance.edge-nodes.*.network_interface.0.address, count.index))} | base64 -d | sudo tee /etc/mantl/private_ip > /dev/null",
      "echo ${base64encode(element(google_compute_instance.edge-nodes.*.network_interface.0.access_config.0.nat_ip, count.index))} | base64 -d | sudo tee /etc/mantl/public_ip > /dev/null",
      "echo ${base64encode(join("\n", google_compute_instance.leader-nodes.*.network_interface.0.address))} | base64 -d | sudo tee /etc/mantl/leaders > /dev/null",
      "echo edge | sudo tee /etc/mantl/role > /dev/null",
    ]
  }

  # run scripts
  provisioner "remote-exec" {
    inline = [ "echo ${base64encode(file("bootstrap-worker.sh"))} | base64 -d | sudo bash" ]
  }
}
