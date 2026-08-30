# BlueBuild Template &nbsp; [![bluebuild build badge](https://github.com/blue-build/template/actions/workflows/build.yml/badge.svg)](https://github.com/blue-build/template/actions/workflows/build.yml)

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

After setup, it is recommended you update this README to describe your custom image.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/blue-build/template:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/blue-build/template:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/blue-build/template
```

# my-kinoite

A declarative replacement for `restoration.sh`, built with [BlueBuild](https://blue-build.org).

Instead of running a script by hand after every reinstall, this repo defines
your whole system in `recipes/recipe.yml`. GitHub Actions builds it into a
container image and publishes it to `ghcr.io`; your machine then just
"upgrades" onto that image the same way it upgrades onto stock Fedora.

## One-time setup

1. **Create the repo.** Easiest path: click "Use this template" on
   [blue-build/template](https://github.com/blue-build/template), or push
   this folder to a new GitHub repo of your own.
2. **Set up image signing** (required by BlueBuild/rpm-ostree so your machine
   trusts images from your own registry). Follow
   [the cosign how-to](https://blue-build.org/how-to/cosign/) — it walks
   through generating a keypair and adding `SIGNING_SECRET` /
   `SIGNING_SECRET_PUBLIC_KEY` as repo secrets/variables. The workflow here
   already expects those names.
3. **Push.** The Action in `.github/workflows/build.yml` builds on push, on
   a daily schedule, and on demand (Actions tab -> "Run workflow"). First
   build takes a while; check the Actions tab for progress.
4. **Rebase your machine onto it, once:**
   ```bash
   # trust the signing key + switch to your image
   sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/<you>/<repo>:latest
   sudo systemctl reboot
   # after reboot, re-pull with signature verification enabled
   sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/<you>/<repo>:latest
   sudo systemctl reboot
   ```
5. **Run the one-time post-boot setup** (Homebrew formulae + `input` group,
   things that can't be baked into a read-only image):
   ```bash
   ujust setup-my-machine
   ```
   Reboot (or log out/in) once afterwards so the new group membership takes
   effect. You don't need to run this again — it's a one-time change to
   your live system, and it survives future image updates.

## Staying updated

You don't rebuild anything by hand:

- **The image**: GitHub Actions rebuilds it automatically every day at
  17:00 UTC and on every push to this repo. `latest` always points at the
  newest successful build, but still pinned to the Fedora version set in
  `recipe.yml` — you won't get silently bumped to the next Fedora release.
- **Your machine**: keeps working exactly like stock Kinoite —
  `rpm-ostree upgrade` (or leave automatic updates enabled) pulls the
  newest layers from `ghcr.io/<you>/<repo>:latest` and reboots to apply.
  Roll back with `rpm-ostree rollback` if something's wrong.

## Changing what's installed

Edit `recipes/recipe.yml` (add/remove RPMs, Flatpaks, etc.), commit, push.
The Action rebuilds; `rpm-ostree upgrade` on your machine picks it up on the
next check.

## Layout

```
recipes/recipe.yml                                   # the whole system, declaratively
files/system/etc/flatpak/overrides/com.obsproject.Studio  # OBS NVIDIA/Wayland env vars
files/justfiles/setup.just                            # one-time post-boot tasks (`ujust setup-my-machine`)
.github/workflows/build.yml                           # builds + publishes the image
```
