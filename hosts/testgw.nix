{ config, pkgs, ... }:

let
  secrets = (import ../secrets_airvpn);
  gateway_interface = "enp0s3";
  gateway_hostname = "ffmuc-wanderer";
  bootloader_disk_device = "/dev/sda";
  rootfs_disk_device = "/dev/sda1";
in

{
  imports = [
    ../modules/default.nix
    ../modules/gateway.nix
    # ../modules/physical.nix
  ];

  services.openvpn.servers.airvpn = secrets.openvpn.airvpn;	

  networking = {
    hostName = gateway_hostname;
    dhcpcd.allowInterfaces = [ gateway_interface ];
  };

  boot.loader.grub.devices = [bootloader_disk_device];
  fileSystems."/".device = rootfs_disk_device;

  freifunk.gateway = {
    enable = true;
    externalInterface = gateway_interface;
    ip4Interfaces = [ "tun0" gateway_interface ];
    ip6Interface = gateway_interface;
    segments = {
      myfoo = {
        baseMacAddress = "EE:EE:00:00:00";
        bridgeInterface = {
          ip4 = [ { address = "192.168.33.1"; prefixLength = 24; } ];
          ip6 = [ { address = "fdef:ffc0:4fff::11"; prefixLength = 64; } ];
        };
        dhcpRanges = [ "192.168.33.100,192.168.33.200,255.255.255.0,1h" ];
        fastdConfigs = {
          backbone = {
            listenAddresses = [ "any" ];
            listenPort = 9999;
            mtu = 1426;
            # Secret: 20adbf7589f61ea403e98113457e8722910f651aa61a73ee8e5d617d060ce872
            # Public: b23fd92e300e2c9cf6328fa88cfb890084d4414aeccabbe17ea829733a3d4563
            secret = "20adbf7589f61ea403e98113457e8722910f651aa61a73ee8e5d617d060ce872";
          };
        };
      };
    };
  };
}
