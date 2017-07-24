function devbox-setup-init {
  set -e

  # Enable debug trace is asked to
  [[ ! -z "$DEBUG" ]] && [[ "$DEBUG" == "on" ]] && set -x

  # Load release info
  . /etc/lsb-release

  # parse arguments
  parse-args

  # init common variables here
  log 'devbox-setup config loaded'
}

function parse-args {
  for ((i=1; i<="$#"; i++)); do
    ARG=${!i}
    NEXT=$(($i + 1))

    case $ARG in
      --non-root-user)
        NON_ROOT_USER="${!NEXT}"
        i=$NEXT
        ;;
      *)
        # unknown option
        echo "Warning! Unknown option passed: $ARG"
        ;;
    esac
  done
}

function require-root {
  if [[ "x$(whoami)" != "xroot" ]]; then
    echo "Running as root required"
    exit 1
  fi
}

function log {
  echo "# $1"
}

function error {
  echo "$@" >&2
}

function fatal {
  error "$@"
  exit 1
}

function package-list-update {
  apt-get update
}

function package-install-from-repos {
  apt-get install -y $@
}

function package-install-from-file {
  log "Manually installing $1"
  dpkg -i "$1"
}

function package-install-from-web {
  URL=$1
  shift

  TMPDIR="$(mktemp -d)"

  if [[ -z "$TMPDIR" ]] || [[ "$TMPDIR" == "/" ]] || [[ "$TMPDIR" == "/tmp" ]]; then
    fatal "Unable to generate temp directory, got $TMPDIR"
  fi

  download-from-web "$URL" "$TMPDIR/package.deb"
  package-install-from-file "$TMPDIR/package.deb"

  rm -f "$TMPDIR/package.deb"
  rmdir "$TMPDIR"
}

function package-install-from-web-with-cache {
  URL=$1
  shift

  CACHE_DOWNLOAD_AS=$1
  shift

  if [[ ! -f "$CACHE_DOWNLOAD_AS" ]]; then
    mkdir -p "$(dirname "$CACHE_DOWNLOAD_AS")"
    download-from-web "$URL" "$CACHE_DOWNLOAD_AS"
  fi

  package-install-from-file "$CACHE_DOWNLOAD_AS"
}

function download-from-web {
  log "Downloading $1 to $2"
  wget "$1" -O "$2"
}

function package-repo-add {
  STRING=$1
  shift

  log "Adding repo $STRING"
  apt-add-repository -y "$STRING"
}

function detect-non-root-user {
  if [[ -z "$NON_ROOT_USER" ]]; then
    NON_ROOT_USER="$SUDO_USER"
    echo "Non-root user to use deducted form \$SUDO_USER: $NON_ROOT_USER"
  fi
}

function require-non-root-user {
  detect-non-root-user

  if [[ -z "$NON_ROOT_USER" ]]; then
    echo "Non root user must be specified for this command"
    echo "Automatic detection (with \$SUDO_USER) failed"
    echo "Pass --non-root-user [user] to specify non-root user manually"
    exit 2
  fi
}

function run_command_as_user {
  RUN_AS=$1
  shift

  COMMAND=$1
  shift

  su "$RUN_AS" -l -s /bin/bash -c "$COMMAND"
}

function reset-list {
  LIST=''
}

function add-to-list {
  LIST="$LIST $@"
}

function md5-check {
  EXPECTED=$1
  shift

  FILENAME=$1
  shift

  ACTUAL="$(md5sum -b "$FILENAME" | awk '{ print $1 }')"

  if [[ "$EXPECTED" != "$ACTUAL" ]]; then
    echo "File $FILENAME MD5 hashsum mismatch!"
    echo "Expected: $EXPECTED"
    echo "Actual:   $ACTUAL"
    exit 3
  fi
}
