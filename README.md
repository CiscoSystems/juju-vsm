# Overview

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

VSM charm is not directly dependent of other OpenStack nodes,
unlike other Cisco charms like VEM or VXGW (VLAN Extended Gateway), 
which are subordinate charms. 

Once the VSM charm is deployed it creates a VSM Virtual Machine (VM)
in the MaaS node. Hence a requirement for VSM to communicate with other
Openstack/Cisco charms is to have L3 connectivity with the rest of 
the MaaS cluster nodes.

# Usage

In order to use Cisco Openstack solution we would need to install 
VSM on a cluster node as well as VEM module that goes into each 
host. As today the VSM charm needs to be network reachable to other 
nodes using the regular mgmt host interface. (This interface is 
specified by the n1kv-phy-intf-bridge configuration parameter of 
the charm).

In order to provide High Availability for VSM you'll need to deploy 
two VSMs (one will be the primary and another the secondary)
in two different hosts. 

In order to deploy the VSMs (both primary and secondary), you will 
need to create a configuration file where you need to provide specific
configuration of your VSM. To differentiate the different primary 
and secondary VSM configuration, we create separate sections for them
on the configuration file and also you deploy as two different service
names.

The VSM charm will automatically create the VSM VM. For that, you'll 
provide (as a minimum):
   - a static IP, netmask and gateway address for network reachability
of this VM (by specifiying the n1kv-vsm-mgmt-ip, n1kv-vsm-mgmt-netmask and
n1kv-vsm-mgmt-gateway configuration parameters). This VM uses the 
interface specified in n1kv-phy-intf-bridge as external network 
interface.
   - domain id that the VSM operates (by the n1kv-vsm-domain-id configuration parameter)
   - password for the administrator to ssh to the VSM VM (n1kv-vsm-password)
   - role which specifies if the VSM will be primary or secondary (n1kv-vsm-role)

For example, you create a myconfig.yaml configuration file with the 
following the minimal mandatory information:

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
        .....
   

Check the config.yaml file for default configuration values and other 
configurable parameters of the VSM charm.

Then you deploy the primary VSM with the following command:

    juju deploy --config myconfig.yaml vsm vsm-primary

Then you deploy the secondary VSM with the following command:

    juju deploy --config myconfig.yaml vsm vsm-secondary

To put VEM into VSM supervision, you need to do the following:

    juju add-relation vsm vem

   
# Contact Information

Author: Marga Millet <millet@cisco.com>  
Report bugs at: http://bugs.launchpad.net/charms/+source/vsm  
Location: http://jujucharms.com/

