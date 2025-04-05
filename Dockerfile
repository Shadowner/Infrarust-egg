# First stage: prepare files with a regular Debian image
FROM debian:12-slim AS prepare

# Create container user required by Pterodactyl with specific UID/GID
RUN groupadd -g 999 container && \
    useradd -d /home/container -u 999 -g 999 -m container

# Create necessary directories
RUN mkdir -p /app/config && \
    chown -R container:container /app && \
    mkdir -p /home/container && \
    chown -R container:container /home/container

# Copy the executable and set permissions
COPY infrarust /bin/infrarust
RUN chmod +x /bin/infrarust

# Second stage: distroless base image
FROM gcr.io/distroless/cc-debian12

# Copy user and group information
COPY --from=prepare /etc/passwd /etc/passwd
COPY --from=prepare /etc/group /etc/group

# Copy the executable
COPY --from=prepare /bin/infrarust /bin/infrarust

# Copy home directory structure
COPY --from=prepare --chown=container:container /home/container /home/container
COPY --from=prepare --chown=container:container /app /app

# Set the user to be used
USER container
ENV USER=container HOME=/home/container

# Setup work directory
WORKDIR /home/container

# Volume and port configuration
VOLUME ["/home/container"]
EXPOSE 25565

# The entrypoint directly calls the infrarust executable since there's no shell in distroless
ENTRYPOINT ["/bin/infrarust"]
# Default arguments - these can be overridden by Pterodactyl
CMD ["--config-path", "/home/container/config.yml", "--proxies-path", "/home/container/proxies"]
