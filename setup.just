# One-time setup tasks that can't be baked into the image itself.
# Run once after your first boot into the image:
#   ujust setup-my-machine

[group('setup')]
setup-my-machine:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "=== Installing Homebrew formulae ==="
    brew install atool btop chezmoi direnv fzf htop imagemagick \
      inotify-tools kopia ncdu portaudio ranger starship uv zoxide

    echo "=== Adding $USER to the 'input' group (for Sunshine/deskflow etc.) ==="
    sudo usermod -aG input "$USER"
    echo "You need to log out and back in (or reboot) for the new group to take effect."

    echo "=== Done. This only needs to be run once per machine. ==="
