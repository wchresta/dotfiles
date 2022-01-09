{ lib, runtimeShell, ... }:

let
  localBin = ".local/bin";

  makeExec = (name: cmd: {
    name = "${localBin}/${name}";
    value = { executable = true; text = cmd; };
  });

  makeScript = (name: cmd: {
    name = "${localBin}/${name}";
    value = {
      executable = true;
      text = ''
        #!${runtimeShell}
        ${cmd}
      '';
    };
  });
in {
  makeBinaries = lib.attrsets.mapAttrs' makeExec;
  makeScripts = lib.attrsets.mapAttrs' makeScript;
}
