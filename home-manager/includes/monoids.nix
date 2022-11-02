{ ... }:

{
  config = {
    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      "netmonoid" = {
        user = "monoid";
        host = "net.monoid.li";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_monoid";
      };

      "netmonoid-deploy" = {
        user = "root";
        host = "net.monoid.li";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids";
      };

      "netmonoid-config" = {
        user = "git-config";
        host = "net.monoid.li";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_config";
      };
    };
  };
}
