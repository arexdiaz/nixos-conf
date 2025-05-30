{ config, lib, pkgs, ... }:

{
  options.preconfs.system.kernel.scx = {
    enable = lib.mkEnableOption "Whether to enable bpf scheduler.";
    scheduler = lib.mkOption {
      type = lib.types.str;
      default = "scx_bpfland";
      description = lib.mdDoc "The scheduler to use for the SCX service.
        Common values include `scx_bpfland`, `scx_rustland`, etc.,
        depending on the available schedulers in the scx package.";
      example = "scx_rustland";
    };
  };

  config = lib.mkIf config.preconfs.system.kernel.scx.enable {
    services.scx = {
      package = pkgs.scx_git.full;
      scheduler = config.preconfs.system.kernel.scx.scheduler;
      enable = true;
    };
  };
}