Overview
--------
There are two major components in a Cisco Nexus 1000V environment:
VSM (Virtual Switch Supervisor) and VEM (Virtual Ethernet Module).
VSM is a virtual machine on a baremetal server. VEM runs inside each host.
VSM, as the name goes, supervises and manages multiple VSMs.
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
host. 

In the config.yaml you can provide general config that will be 
common to all VSM hosts in environment. To differentiate the 
different primary and secondary VSM configuration, we create 
separate sections for them, for example:

vsm-primary:

    n1kv-vsm-domain-id: 101

    n1kv-vsm-password: password

    n1kv-vsm-name: vsm-p

    n1kv-vsm-role: primary

    n1kv-vsm-ip: 10.10.10.10

    n1kv-vsm-mgmt-netmask: 255.255.255.0

    n1kv-mgmt-gateway: 10.10.10.1

    .....

vsm-secondary:

    n1kv-vsm-domain-id: 101

    n1kv-vsm-password: password

    n1kv-vsm-name: vsm-s

    n1kv-vsm-role: secondary

    n1kv-vsm-ip: 0.0.0.0

    n1kv-vsm-mgmt-netmask: 0.0.0.0

    n1kv-mgmt-gateway: 0.0.0.0

    n1kv-vsm-ctrl-mac: 00:10:11:72:41:01

    n1kv-vsm-mgmt-mac: 00:10:11:72:41:02

    n1kv-vsm-pkt-mac: 00:10:11:72:41:03

    .....
   
At deployment time, for primary:

   juju deploy --config=vsm-config vsm vsm-primary

At deployment time, for secondary:

   juju deploy --config=vsm-config vsm vsm-secondary

To put VEM into VSM supervision, user needs to do the following:

   juju add-relation vsm vem

Contact Information
-------------------
Author: Marga Millet <millet@cisco.com> 
        Mani Devarajan <mdevaraj@cisco.com>

Report bugs at: http://bugs.launchpad.net/charms/+source/vsm

Location: http://jujucharms.com/charms/distro/vsm


