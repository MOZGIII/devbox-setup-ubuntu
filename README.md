# devbox-setup-ubuntu

A set of simple shell scripts to install stuff I use on my development boxes.

## Requirements

This set of scripts expects you to have `bash`, `wget`, `curl` and other core utils.

## Installation and usage

Clone the repo somewhere and run scripts you like from `bin`.
Use `sudo`. Some scripts require non-root user - you can specify it manually with `--non-root-user [user]` option or in will be deducted form `$SUDO_USER`.

### Quick install

Quick install with bootstrap script:

    \curl -sS https://raw.githubusercontent.com/MOZGIII/devbox-setup-ubuntu/master/bootstrap/install | bash

## Testing

Use vagrant and temporary virtual machine to keep your system safe.
