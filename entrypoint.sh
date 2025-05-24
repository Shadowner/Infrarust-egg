#!/bin/bash

# Forward signals to child process based on platform
function handle_signal {
  kill -$1 "$child_pid" 2>/dev/null
}

MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# Prepare the proxies

# check if the folder proxies doesn't exists
if [ ! -d "/home/container/proxies" ]; then
    # create the folder
    mkdir /home/container/proxies
fi

function createProxyYml {

    local proxyNumber=$1
    local domains="DOMAINS_${proxyNumber}"
    local addresses="ADDRESSES_${proxyNumber}"

    # Check if the env variable is set
    if [ -z "${!domains}" ]; then
        echo "The domains variable is not set. Please set it to the $1 domain of the proxy"
        exit 1
    fi

    # Check if the env variable is set
    if [ -z "${!addresses}" ]; then
        echo "The addresses env variable is not set. Please set it to the $1 domain of the proxy"
        exit 1
    fi

    # If file exists, delete it
    if [ -f "/home/container/proxies/$1.yml" ]; then
        rm /home/container/proxies/$1.yml
    fi
    echo "addresses:" >>"/home/container/proxies/$1.yml"
    echo "${!addresses}" | while IFS=',' read -r address; do
        echo "  - $address" >>"/home/container/proxies/$1.yml"
    done
}


# Check if PROXY_COUNT is set if not assume the User configured everything manually
if [ -n "$PROXY_COUNT" ]; then
    # Check if it's a number
    if ! [[ $PROXY_COUNT =~ ^[0-9]+$ ]]; then
        echo "The PROXY_COUNT env variable is not a number"
        exit 1
    fi

        # Loop through the number of proxies and create the yml files
    for i in $(seq 1 $PROXY_COUNT); do
        createProxyYml $i
    done
fi


# Set up signal traps for Unix environment (Docker)
trap 'handle_signal TERM' TERM
trap 'handle_signal INT' INT
trap 'handle_signal HUP' HUP
trap 'handle_signal USR1' USR1
trap 'handle_signal USR2' USR2

# Echo and start the command
${MODIFIED_STARTUP} &

# Store child PID
child_pid=$!

# Wait for the child process to complete
wait "$child_pid"
exit_code=$?

exit $exit_code