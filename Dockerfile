
# Build stage
FROM alpine:edge AS build

# enable community repo skipping the media cdrom dir
RUN sed -i 's/^#http/http/g' /etc/apk/repositories
RUN <<EOF
apk update
apk upgrade
apk add git dotnet10-sdk curl bash
EOF

## Prepare the watchdog binaries
RUN git clone https://github.com/space-wizards/SS14.Watchdog.git /repo
# -r linux-musl-x64 for musl support when that gets stabalized
ENV DOTNET_NOLOGO=true
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN cd /repo && dotnet publish SS14.Watchdog -c Release -r linux-x64 --no-self-contained
RUN mkdir /watchdog
# TODO fix this globbing in case of dotfiles
RUN cp -ar /repo/SS14.Watchdog/bin/Release/net10.0/linux-x64/publish/* /watchdog

## Prepare the dotnet binaries for the debian host
# RUN curl https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh -o /dotnet-install.sh
# RUN chmod +x /dotnet-install.sh
ADD --chmod=777 https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh /dotnet-install.sh
RUN /dotnet-install.sh --channel "10.0" --install-dir "/dotnet" --architecture "x64" --os "linux"
# Temporary, for compatibility with older stations that do not yet run dotnet10
# RUN /dotnet-install.sh --channel "9.0" --install-dir "/dotnet" --architecture "x64" --os "linux"

# Server stage
# FROM alpine:edge AS server # TODO come back to alpine when watchdog stabalizes musl support
FROM debian:trixie-slim AS server

# Install runtime dependencies
RUN <<EOF
apt-get -y update
apt-get -y upgrade
apt-get -y install git libicu76
EOF

# Prepare dotnet
COPY --from=build /dotnet /dotnet
ENV DOTNET_ROOT=/dotnet
RUN ln -s /dotnet/dotnet /bin/dotnet

# Prepare watchdog
COPY --from=build /watchdog /watchdog

# we cannot know the number of ports or which ports will be used by the user, so instead of relying on -P the user must specify their port range or individual ports
# EXPOSE 1212/tcp
# EXPOSE 1212/udp

# External access to watchdog
EXPOSE 5000/tcp

# Create the config volume
VOLUME [ "/config" ]

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the entry point for the container
ENTRYPOINT ["/start.sh"]

