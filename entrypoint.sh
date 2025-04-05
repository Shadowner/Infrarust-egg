#!/bin/bash

# Forward signals to child process based on platform
function handle_signal {
  kill -$1 "$child_pid" 2>/dev/null
}

# Set up signal traps for Unix environment (Docker)
trap 'handle_signal TERM' TERM
trap 'handle_signal INT' INT
trap 'handle_signal HUP' HUP
trap 'handle_signal USR1' USR1
trap 'handle_signal USR2' USR2

# Echo and start the command
${STARTUP} &

# Store child PID
child_pid=$!

# Wait for the child process to complete
wait "$child_pid"
exit_code=$?

exit $exit_code