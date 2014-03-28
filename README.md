Overview
--------
There are two major components in a Cisco Nexus 1000V environment: 
VSM (Virtual Switch Supervisor) and VEM (Virtual Ethernet Module).
VSM is a virtual machine on a baremetal server. VEM runs inside each host. 
VSM, as the name goes, supervises and manages multiple VEMs.  
In the OpenStack deployment environment, VSM prepares north 
bound REST APIs that communicate with OpenStack Nova Cloud 
Controller for network profile configuration, policy profile 
notification, network creation, subnet creation, and virtual 
machine workload administration.

VSM charm installs the Nexus 1000V virtual switch Supervisor 
Module virtual machine onto a MaaS cluster node. A cluster can 
have up to 2 VSM in active/standby mode (generally in two different servers).
When the active one fails, the standby will take over within bounded time.

Usage
-----
In order to use Cisco Openstack solution we would need to install 
VSM on a cluster node as well as VEM module that goes into each 
host. In order to provide High Availability for VSM you'll need
to deploy two VSMs (one will be the primary and another the secondary)
in two different hosts. 

In order to deploy the VSMs (both primary and secondary), you will 
need to create a configuration file where you need to provide specific
configuration of your VSM. To differentiate the different primary 
and secondary VSM configuration, we create separate sections for them
on the configuration file and also you deploy as two different service
names.

For example, you create a myconfig.yaml configuration file with the 
following info:

vsm-primary:

    n1kv-vsm-domain-id: 101

    n1kv-vsm-password: password

    n1kv-vsm-name: vsm-p

    n1kv-vsm-role: primary

    n1kv-vsm-mgmt-ip: 10.10.10.10

    n1kv-vsm-mgmt-netmask: 255.255.255.0

    n1kv-vsm-mgmt-gateway: 10.10.10.1

    .....

vsm-secondary:

    n1kv-vsm-domain-id: 101

    n1kv-vsm-password: password

    n1kv-vsm-name: vsm-s

    n1kv-vsm-role: secondary

    n1kv-vsm-vsm-ip: 0.0.0.0

    n1kv-vsm-mgmt-netmask: 0.0.0.0

    n1kv-vsm-mgmt-gateway: 0.0.0.0

    n1kv-vsm-ctrl-mac: 00:10:11:72:41:01 

    n1kv-vsm-mgmt-mac: 00:10:11:72:41:02

    n1kv-vsm-pkt-mac: 00:10:11:72:41:03

    .....
   

Then you deploy the primary VSM with the following command:

   juju deploy --config myconfig.yaml vsm vsm-primary

Then you deploy the secondary VSM with the following command:

   juju deploy --config myconfig.yaml vsm vsm-secondary

To put VEM into VSM supervision, you need to do the following:

   juju add-relation vsm vem


   
Contact Information
-------------------
Author: Marga Millet <millet@cisco.com>


Report bugs at: http://bugs.launchpad.net/charms/+source/vsm

Location: http://jujucharms.com/charms/distro/vsm


