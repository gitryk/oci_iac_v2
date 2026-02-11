#!/bin/bash
set -euxo pipefail # Terminate script on error, undefined variables, or pipe failures

#Initial variable declarations
EXTRA_INSTALL_UBUNTU="vim cron wget vim traceroute tcpdump"
EXTRA_INSTALL_ROCKY="vim cronie cockpit wget vim traceroute tcpdump"
ENV_OS="${os_image}"
ENV_Target="${install_target}"
TS_KEY="${ts_authkey}"

#Wait for internet connectivity
until curl -s --connect-timeout 2 http://www.google.com &> /dev/null
do
  sleep 2
done

#function declaration
function disable_ipv6 { #ipv6 disable
  echo -e 'net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1' | tee -a /etc/sysctl.conf
  sysctl -p
}

function enable_ip_forward { #ip forward enable
  echo -e 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf
  sysctl -p
}

function dependency { #set timezone and install dependencies
  if [[ "$ENV_OS" == "rocky" ]]; then
    timedatectl set-timezone Asia/Seoul
    dnf update -y
    dnf install -y $EXTRA_INSTALL_ROCKY
    systemctl enable --now cockpit.socket
  elif [[ "$ENV_OS" == "ubuntu" ]]; then
    timedatectl set-timezone Asia/Seoul
    apt-get update
    apt-get upgrade -y
    apt-get install -y $EXTRA_INSTALL_UBUNTU
  fi
}

function install_wireguard { #wireguard install
  if [[ "$ENV_OS" == "rocky" ]]; then
    dnf install epel-release wireguard-tools -y

    echo "${wireguard_conf}" | base64 -d > /etc/wireguard/wg0.conf
    chmod 600 /etc/wireguard/wg0.conf

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0 
  elif [[ "$ENV_OS" == "ubuntu" ]]; then
    apt install wireguard -y

    echo "${wireguard_conf}" | base64 -d > /etc/wireguard/wg0.conf
    chmod 600 /etc/wireguard/wg0.conf

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0 
  fi  
}

function copy_log { #copy cloud-init log to home directory
  if [[ "$ENV_OS" == "rocky" ]]; then
    install -o rocky -g rocky -m 644 /var/log/cloud-init-output.log /home/rocky/init_log.txt || true
  elif [[ "$ENV_OS" == "ubuntu" ]]; then
    install -o ubuntu -g ubuntu -m 644 /var/log/cloud-init-output.log /home/ubuntu/init_log.txt || true 
  fi
}

function install_tailscale { #tailscale install for debug
  curl -fsSL https://tailscale.com/install.sh | sh
  systemctl enable --now tailscaled
  tailscale up --authkey="$TS_KEY" --hostname="oci-vm-main"
}

#Main Execution
dependency
if [[ "$ENV_Target" == "gateway" ]]; then
  disable_ipv6
  enable_ip_forward
  install_wireguard  
elif [[ "$ENV_Target" == "central" ]]; then
  disable_ipv6
  #install_tailscale
fi

copy_log