{ pkgs, ... }:
let
  gpuIDs = [
    # Tesla P40
    "10de:1b38"
  ];
  gpu_pci = "07:00.0";
in
{
  security.polkit.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMF.fd ];
      };
    };

  };
  users.users.jade.extraGroups = [ "libvirtd" ];
  users.users.willow.extraGroups = [ "libvirtd" ];
  environment.systemPackages = [ pkgs.virtiofsd ];

  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
  ];
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "kvm_amd.npt=1"
    ("vfio-pci.ids=" + builtins.concatStringsSep "," gpuIDs)
    "pcie_acs_override=downstream"
  ];
  boot.kernel.sysctl = {
    # 2KiB hugepages, add enough for 24gb plus some
    "vm.nr_hugepages" = 13 * 1024;
  };
}
