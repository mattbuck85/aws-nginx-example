#/bin/bash
terraform show | ./get_terraform_vars.py ansible-hosts public_ip
