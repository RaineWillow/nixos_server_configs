# NOTES


# brain-ghost
For some reason, the efi firmware periodically breaks on nix (ive never seen this issue on other machines)
the way to fix it is to go into the xml for the vm and delete the <loader> and <nvram> lines and hit apply
