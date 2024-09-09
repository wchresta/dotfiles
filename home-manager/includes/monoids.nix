{ ... }:

{
  config = {
    programs.ssh.enable = true;
    programs.ssh.matchBlocks = {
      "netmonoid" = {
        user = "monoid";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_monoid";
      };

      "netmonoid-deploy" = {
        user = "root";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids";
      };

      "netmonoid-git" = {
        user = "gitea";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_gitea";
      };

      "gitmonoid" = {
        user = "gitea";
        port = 144;
        identityFile = "~/.ssh/monoids/id_gitea";
      };

      "git.monoid.li" = {
        user = "gitea";
        port = 144;
        identityFile = "~/.ssh/monoids/id_gitea";
      };

      "netmonoid-config" = {
        user = "git-config";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_config";
      };

      "netmonoid-monitor" = {
        user = "git-monitor";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_monitor";
      };

      "netmonoid-susannachresta" = {
        user = "git-susannachresta";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_susannachresta";
      };

      "netmonoid-idlez" = {
        user = "git-idlez";
        host = "netmonoid";
        port = 144;
        identityFile = "~/.ssh/monoids/id_monoids_monitor";
      };
    };
  };
}
