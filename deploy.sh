#!/bin/sh
HOST=brain-ghost
nixos-rebuild switch --flake ".#${HOST}" --target-host "${HOST}" --build-host "${HOST}" --sudo --ask-sudo-password
