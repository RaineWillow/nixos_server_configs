{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    graalvmPackages.graalvm-oracle
  ];
}
