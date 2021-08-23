---
title: "Setting up Kubernetes on a Raspberry Pi 4 with NixOS"
date: 2021-08-22T12:41:19-06:00
draft: false
description: "Simple declarative personal Kubernetes cluster"
---

I use Kubernetes to deploy applications at work and I love how simple it is to use. Instead of paying Google or Amazon for a cluster, I'm repurposing a few Raspberrry Pi 4's that I already own to run a Kubernetes cluster. This is my first forray into running NixOS and I am absolutely floored with how easy and repeatable it is to set up a Kubernetes cluster. It worked for me and it will work for you.

If you haven't installed NixOS on your Raspberry Pi 4 yet, [follow the official docs](https://nix.dev/tutorials/installing-nixos-on-a-raspberry-pi) to get started.

## Single node cluster

If you only have one Pi at your disposal, we can easily create a single node cluster using K3s.

```
{ config, pkgs, lib, ... }:

let
  user = "YOUR_USER";
  password = "YOUR_PASSWORD";
  sshPubKey = "YOUR_PUBLIC_SSH_KEY";
  SSID = "YOUR_WIFI_SSID";
  SSIDpassword = "YOUR_WIFI_PASSWORD";
  hostname = "HOSTNAME_FOR_YOUR_PI";
in {
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/d2d9a58a5c03ea15b401c186508c171c07f9c4f1.tar.gz" }/raspberry-pi/4"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 6443 ];
      enable = true;
      trustedInterfaces = [ "cni0" ];
    };
    hostName = hostname;
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [ "wlan0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    k3s
    vim
  ];

  boot.kernelParams = [
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

  services.k3s.enable = true;

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      openssh.authorizedKeys.keys = [
        sshPubKey
      ];
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" ];
    };
  };
}
```

After adding this config to your Pi, just run `nixos-rebuild boot; reboot` to apply it.

At this point, K3s should be running and you'll be able to use `kubectl` to interact with your cluster. `k3s kubectl cluster-info` should return something like this:
```
Kubernetes control plane is running at https://127.0.0.1:6443
CoreDNS is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://127.0.0.1:6443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy
```

### Notable config elements

I want to take a moment and give context for some of the config.

#### Firewall

```
firewall = {
  allowedTCPPorts = [ 6443 ];
  enable = true;
  trustedInterfaces = [ "cni0" ];
};
```

Opening port `6443` on the Pi's firewall is required for the Kubernetes API to be accessed by worker nodes if you choose to add them in the future. Adding `cni0` to the trusted interfaces is required for applications running in Kubernetes to talk to one another.

#### Kernel Params

```
boot.kernelParams = [
  "cgroup_memory=1"
  "cgroup_enable=memory"
];
```

When I first started k3s I noticed that the service wasn't starting. Using `journalctl -xe` I saw the following error:
```
Aug 22 17:25:29 rpi4-nixos-0 k3s[56281]: time="2021-08-22T17:25:29.842551411Z" level=fatal msg="failed to find memory cgroup (v2)
```
I found this suggestion on this [Github issue](https://github.com/k3s-io/k3s/issues/2067#issuecomment-664048424) which lead me to add the kernal parameters above. Now k3s starts without issue.

## Adding additional nodes (optional)

If you have more than one Pi laying around, add the following config to them and repeat as many times as necessary to build out all the nodes for your cluster. You can find the API token by running the following on your control node: `cat /var/lib/rancher/k3s/server/token`.

```
{ config, pkgs, lib, ... }:

let
  user = "YOUR_USER";
  password = "YOUR_PASSWORD";
  sshPubKey = "YOUR_PUBLIC_SSH_KEY";
  SSID = "YOUR_WIFI_SSID";
  SSIDpassword = "YOUR_WIFI_PASSWORD";
  hostname = "HOSTNAME_FOR_YOUR_PI";
  k8sApiServerAddr = "https://IP_FOR_YOUR_CONTROL_NODE:6443";
  k8sApiServerToken = "TOKEN_FOR_YOUR_CONTROL_NODE";
in {
  imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/d2d9a58a5c03ea15b401c186508c171c07f9c4f1.tar.gz" }/raspberry-pi/4"];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ "cni0" ];
    };
    hostName = hostname;
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
      interfaces = [ "wlan0" ];
    };
  };

  environment.systemPackages = with pkgs; [
    k3s
    vim
  ];

  boot.kernelParams = [
    "cgroup_memory=1"
    "cgroup_enable=memory"
  ];

  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = k8sApiServerAddr;
    token = k8sApiServerToken;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      openssh.authorizedKeys.keys = [
        sshPubKey
      ];
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" ];
    };
  };
}


```

Just like before, run `nixos-rebuild boot; reboot` to apply the config.

## Interacting with your cluster from your local machine

You'll need to add your cluster's config to your `~/.kube/config` file to be able to talk to it from your local machine. I haven't found a great way to do this yet but here's the method I used. Please [open an issue or pr](https://github.com/nateinaction/n8.gay/issues) if you have a better way.

On your control node, extract the kubernetes config from k3s and modify some of the values like IP and name:

```
k3s kubectl config view --flatten --minify | sed 's/127\.0\.0\.1/YOUR\.K8S\.CONTROL\.IP/' | sed 's/default/YOUR_CLUSTER_NAME/'
```

Then copy the entries under `clusters`, `users`, and `contexts` to your local machine's `~/.kube/config` file.

Now you should be able to use `kubectl` to interact with your cluster.
