{ config, pkgs, ... }:

let
  secrets = (import ../secrets_airvpn);
  gateway_interface = "enp0s3"
  gateway_hostname = "ffmuc-wanderer"
in

{
  imports = [
    ../modules/default.nix
    ../modules/gateway.nix
    ../modules/physical.nix
  ];

  services.openvpn.servers.airvpn = secrets.openvpn.airvpn;

  i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "de"; # wer eine deutsche Tastatur will
     defaultLocale = "en_EN.UTF-8"
  }

  networking = {
    hostName = gateway_hostname;
    dhcpcd.allowInterfaces = [ gateway_interface ];
  };

  boot.loader.grub.devices = ["/dev/sda"];
  fileSystems."/".device = "/dev/sda1";

  freifunk.gateway = {
    enable = true;
    externalInterface = "enp0s3";
    ip4Interfaces = [ "tun0" gateway_interface ];
    ip6Interface = gateway_interface;
    segments = {
      myfoo = {
        baseMacAddress = "EE:EE:EE:00:00:00";
        bridgeInterface = {
          ip4 = [ { address = "192.168.33.1"; prefixLength = 24; } ];
          ip6 = [ { address = "fdef:ffc0:4fff::11"; prefixLength = 64; } ];
        };
        dhcpRanges = [ "192.168.33.100,192.168.33.200,255.255.255.0,1h" ];
        fastdConfigs = {
          backbone = {
            listenAddresses = [ "any" ];
            listenPort = 9999;
            mtu = 1428;
            # fastd public: cc702a59de69623c2bb759a3c9dcac19c24e3ca597387b8463f8d130a6f640c0
            secret = "f026925227659628400350407340eef4e155d0db1fd85d41c9f86764cba91c6a";
          };
        };
        portBalancings = [
          { from = 10000; to = 10099; }
          { from = 10001; to = 10098; }
        ];
      };
    };
  };
}
