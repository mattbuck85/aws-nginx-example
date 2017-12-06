#!/usr/bin/python3


import sys
if __name__ == "__main__":
    tfstate_file = open("terraform/terraform.tfstate")
    tfstate = tfstate_file.read()
    #sanitize the tfstate for python
    tfstate = tfstate.replace("true", "True")
    tfstate = tfstate.replace("false", "False")
    tfstate = eval(tfstate)
    #we only want aws instance data
    resources = tfstate['modules'][0]['resources']
    instance_keys = list(filter(lambda key: key[0:12] == "aws_instance", resources.keys()))
    aws_instance_data = {}
    for key,value in resources.items():
        if key in instance_keys:
            aws_instance_data[key] = value['primary']['attributes']
    #Export hosts in ansible config file format
    if sys.argv[1] == "ansible-hosts":
        regrouped_data = {}
        for host, data in aws_instance_data.items():
            if data['tags.group'] in regrouped_data:
                regrouped_data[data['tags.group']][host] = data
            else:
                regrouped_data[data['tags.group']] = {host:data}
        sys.stdout.write("[all:vars]\n")
        sys.stdout.write("ansible_connection=ssh\n")
        sys.stdout.write("ansible_ssh_user=centos\n")
        for group, host_data in regrouped_data.items():
            sys.stdout.write('[%s]\n' % group)
            for host, data in host_data.items():
                sys.stdout.write(host + " ansible_ssh_host=" + data[sys.argv[2]] + "\n")
 
    if sys.argv[1] == "resources":
        sys.stdout.write("\n".join(aws_instance_data.keys()))
