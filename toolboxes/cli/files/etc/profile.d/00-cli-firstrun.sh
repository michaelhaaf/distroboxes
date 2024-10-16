# shellcheck shell=sh disable=SC1091
# Adapted from https://github.com/ublue-os/toolboxes/blob/main/toolboxes/bluefin-cli/files/etc/profile.d/00-bluefin-cli-brew-firstrun.sh
if test "$(id -u)" -gt "0"; then
  blue=$(printf '\033[38;5;32m')
  bold=$(printf '\033[1m')
  normal=$(printf '\033[0m')

  if test ! -d /usr/local/share/bash-completion/completions; then
    printf "Setting up Tab-Completions...\t\t\t "
    sudo mkdir -p /usr/local/share/bash-completion
    sudo mount --bind /run/host/usr/share/bash-completion /usr/local/share/bash-completion
    if test -x /run/host/usr/bin/ujust; then
      sudo ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/ujust
    fi
    printf "%s[ OK ]%s\n" "${blue}" "${normal}"
  fi

  if test ! -f /etc/cli.nix-init; then
    printf "Initializing nix...\n\n"
    sudo touch /etc/cli.nix-init
    if test ! -d /home/nix; then
      printf "No /home/nix found, creating and bind mounting to /nix...\t\t\t"
      sudo mkdir -p /home/nix
      sudo mount --bind /nix /home/nix/
      printf "%s[ OK ]%s\n" "${blue}" "${normal}\n\n"
    else
      printf "/home/nix found, bind mounting to /nix...\t\t\t"
      sudo mount --bind /home/nix /nix
      printf "%s[ OK ]%s\n" "${blue}" "${normal}\n\n"
    fi
    if ! pgrep -x nix-daemon >/dev/null; then
      sudo rc-service nix-daemon restart
      sudo rc-service nix-daemon status
    fi
    printf "Running home-manager...\t\t\t"
    cd ~/.config/home-manager/
    nix run . switch
    cd -
    printf "%s[ OK ]%s\n" "${blue}" "${normal}"
  fi

  if test ! -f /etc/cli.firstrun; then
    sudo touch /etc/cli.firstrun
    printf "\ncli first run complete.\n\n"
  fi

fi
