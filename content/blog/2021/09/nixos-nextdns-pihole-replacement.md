---
title: "Replacing Pihole with NixOS and NextDNS"
date: 2021-09-10T12:41:19-06:00
draft: false
description: "Declarative encrypted DNS for my home network"
---

I started playing with NixOS a few weeks ago when I set up my [Raspberry Pi Kubernetes cluster](../08/raspberrypi-4-nixos-kubernetes.md). For my next project, I wanted to replace my Rasbperry Pi OS based Pihole with something based on NixOS. Pihole does not have a NixOS module available and a friend of mine (thanks William!) told me about [NextDNS](https://nextdns.io/?from=u94ay4xa) so I decided to take a look. I loved the easy to use web ui and the simplicity of their [Privacy Policy](https://web.archive.org/web/20210903010445/https://nextdns.io/privacy).

Before officially moving away from Pihole I decided to write down what I wanted out of my home network DNS solution.
  1. Support for ad, tracker and malware blocking
  2. DNS requests are encrypted before leaving the network

NextDNS supports both of these requirements as long as I continue to run a DNS proxy on my home network. Luckily, NextDNS distributes their own golang based [DNS-over-HTTPS (DOH) proxy](https://github.com/nextdns/nextdns) and luckier yet, it's already [packaged for NixOS](https://github.com/NixOS/nixpkgs/blob/nixos-21.05/pkgs/applications/networking/nextdns/default.nix). Here's the NixOS config I'm using to proxy DNS to NextDNS:

```
{ config, pkgs, ... }:

let
  nextdnsConfig = "YOUR_CONFIG_ID";
in {
  environment.systemPackages = with pkgs; [ nextdns ];

  services.nextdns = {
    enable = true;
    arguments = [ "-config" nextdnsConfig "-listen" "0.0.0.0:53" ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
    nameservers = [ "45.90.28.239" "45.90.30.239" ];
  };
}
```
