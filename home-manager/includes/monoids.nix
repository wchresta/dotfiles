{ ... }:

{
  config = {
    programs.ssh.matchBlocks = {
      "netmonoid" = {
        user = "root";
        port = 144;
        identityFile = "~/.ssh/id_monoids";
      };
    };
  };
}
