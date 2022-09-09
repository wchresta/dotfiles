{ ... }:

{
  config = {
    programs.ssh.matchBlocks = {
      "netmonoid" = {
        user = "monoid";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/id_monoids_monoid";
      };

      "netmonoid-deploy" = {
        user = "root";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/id_monoids";
      };

      "netmonoid-config" = {
        user = "config";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/id_monoids_config";
      };
    };
  };
}
