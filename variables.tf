variable leader_count { default = 3 }
variable leader_type { default = "n1-standard-1" }
variable leader_volume_size { default = "20" } # size is in gigabytes
variable worker_count { default = 3 }
variable worker_type { default = "n1-standard-1" }
variable worker_volume_size { default = "20" } # size is in gigabytes
variable name { default = "mantl" }
variable network_ipv4 { default = "10.0.0.0/16" }
variable project {}
variable region {}
variable ssh_key { default = "~/.ssh/id_rsa.pub" }
variable ssh_user { default = "centos" }
variable zone {}
variable credential_file {}
