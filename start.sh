#!/bin/bash

set -euo pipefail

if [ ! -e /config/appsettings.yml ]
then
    echo 'ERROR: /config/appsettings.yml is missing and is required for watchdog to function!'
    echo 'TIP: Did you mount the /config volume and place the required files inside? Check out the README.md for more details!'
    exit 1
fi
rm /watchdog/appsettings.yml
ln -s /config/appsettings.yml /watchdog/appsettings.yml

if [ ! -e /config/data.db ]
then
    echo 'ERROR: /config/data.db is missing and is required for watchdog to function!'
    echo 'TIP: Did you mount the /config volume and place the required files inside? Check out the README.md for more details!'
    exit 1
fi
# rm /watchdog/data.db
ln -s /config/data.db /watchdog/data.db

mkdir -p /watchdog/instances
for instance in /config/instances/*
do
    echo -- "Linking ${instance}!"
    ln -s -T "${instance}" "/watchdog/instances/$(basename "${instance}")"
done

export DOTNET_NOLOGO=true
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Start the original command
cd /watchdog # unsure if cd is required instead of hard path executing
./SS14.Watchdog "$@"
