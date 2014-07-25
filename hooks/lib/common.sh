#!/bin/bash

LOG_TERMINAL=0
export LOG_TERMINAL VSM_NAME VSM_ISO_DIR VSM_VM_DIR VSM_VM_XML

VSM_NAME=$(config-get n1kv-vsm-name)
VSM_ISO_DIR="/opt/cisco/iso"
VSM_VM_DIR="/var/spool/cisco/vsm"
VSM_VM_XML="vsm_vm.xml"


function logger
{
    if [ $LOG_TERMINAL -eq 1 ]; then
        echo $1
    else
        juju-log $1
    fi
}

# Checks if a ip is valid. If so, then it returns 1, else it returns 0
function is_valid_ip
{
    local  ip=$1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        if [ $? -eq 0 ]; then
            return 1
        else
            return 0
        fi
    fi
    return 0
}

# Function than given a mac address on the format XX:XX:XX:XX:XX:XX,
# it returns 1 if is valid or 0 if it is not.
function is_valid_mac
{
    local mac=$(echo $1 | sed -n "/^\([0-9A-F][0-9A-F]:\)\{5\}[0-9A-F][0-9A-F]$/Ip" | awk '{print toupper($0)}' )

    if [ "$mac" == "" ]; then
        return 0
    else
        return 1
    fi
}

# Returns 0 if VSM is not running
function is_vsm_vm_running
{
    local run=$(sudo virsh list --all | grep ${VSM_NAME} | awk '{print $NF}')
    if [ "$run" == "running" ]; then
        return 1
    else
        return 0
    fi
}

# Returns 0 if VSM VM is not created
function is_vsm_vm_created
{
    if [ `/usr/bin/virsh list --all | grep -c ${VSM_NAME}` -eq 1 ]; then
        return 1
    else
        return 0
    fi
}

# It creates a persistent VSM VM if it was not created already
# Returns 1 if it was not able to create it
function create_vsm_vm
{
    juju-log "Check if ${VSM_NAME} vm already exists"

    if [ `/usr/bin/virsh list --all | grep -c ${VSM_NAME}` -eq 1 ]; then
        juju-log "vsm vm is already created"
        return 0
    fi

    juju-log "Define vsm vm"
    if [ ! -f ${VSM_VM_DIR}/${VSM_VM_XML} ]; then
        juju-log "Error: ${VSM_NAME} template does not exist"
        return 1
    fi
    /usr/bin/virsh define ${VSM_VM_DIR}/${VSM_VM_XML}
    if [ "`sudo virsh list --all | awk '/shut off/{print $2}'`" != "${VSM_NAME}" ]; then
        juju-log "start: unable to define vsm vm"
        return 1
    fi
}

function start_vsm_vm
{
    juju-log "Get vsm vm state"
    state="`sudo virsh dominfo ${VSM_NAME} | awk '/State:/' | cut -d: -f 2 | tr -d ' '`"
    case $state in
        running)   juju-log "vsm ${VSM_NAME} is already runnning"
                   ;;
        shut*)     juju-log "need to restart vsm ${VSM_NAME}"
                   /usr/bin/virsh start ${VSM_NAME}
                   if [ $? -eq 1 ]; then
                       juju-log "Error: vsm vm is shutdown but couldn't restart it"
                       return 1
                   fi
                   # Restart ovs to handle server reboot case
                   service openvswitch-switch restart
                   ;;
        *)         juju-log "Unknown state($state) of vsm ${VSM_NAME}"
                   ;;
    esac
    return 0
}

export -f logger is_valid_ip is_valid_mac is_vsm_vm_running is_vsm_vm_created create_vsm_vm start_vsm_vm

