#!/usr/bin/env bash

# Argumments:
# $1 - openrc or systemd. default is autodetect (systemd if both present)
######
## Error table:
## +---+-----------------+
## | 2 | Can't get sudo  |
## | 3 | Failed to pushd |
## | 4 | Failed to popd  |
## | 5 | Failed to build |
## +---+-----------------+
######

current-script-source () {
  cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd
}

SD=$(current-script-source)  # "script directory"
WD="$SD/../"                 # "working directory" (project root directory)

# Detect method of gaining root permissions (if required)
if [ -f "$(which sudo)" ]; then
  SUDO=sudo
elif [ "$(whoami)" = "root" ]; then
  SUDO=""
else
  echo "Please install sudo or run as root."
  exit 2
fi

PWD=$(pwd)  # save previous directory
pushd "$WD" > /dev/null 2>&1 || (echo "Failed to push directory!"; exit 3)

echo "Building..."
mvn package > /dev/null 2>&1 || { echo "Build failed!"; exit 5; }
echo "Build complete."

echo "Installing..."
$SUDO mkdir -p /usr/local/etc/melodybot /usr/local/bin/melodybot /var/log/melodybot/
$SUDO cp "$WD/config.txt" /usr/local/etc/melodybot/
$SUDO cp "$WD/target/JMusicBot-Snapshot-All.jar" /usr/local/bin/melodybot/JMusicBot-0.36-All.jar
chmod +x "$WD/scripts/openrc-melodybot.sh"

if [ -d /etc/systemd/system ] && { [ -z "$1" ] || [ "$1" = "systemd" ]; }; then
  echo "Installing systemd"
  $SUDO cp "$WD/scripts/melodybot.service" /etc/systemd/system/
else
  echo "Installing openrc"
  $SUDO cp "$WD/scripts/openrc-melodybot.sh" /etc/init.d/melodybot
fi
echo "Install complete."

popd > /dev/null 2>&1 || { echo "Failed to return to $PWD!"; exit 4; }
