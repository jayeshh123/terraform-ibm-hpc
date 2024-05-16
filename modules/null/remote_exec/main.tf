###################################################
# Copyright (C) IBM Corp. 2023 All Rights Reserved.
# Licensed under the Apache License v2.0
###################################################

/*
    This module used to run null for LSF utilities
*/

resource "null_resource" "remote_exec" {
  count = length(var.cluster_host)
  connection {
    type                = "ssh"
    host                = var.cluster_host[count.index]
    user                = var.cluster_user
    private_key         = var.cluster_private_key
    bastion_host        = var.login_host
    bastion_user        = var.login_user
    bastion_private_key = var.login_private_key
    timeout             = var.timeout
  }

  provisioner "remote-exec" {
    inline = var.command
  }

  triggers = {
    build = timestamp()
  }
}
