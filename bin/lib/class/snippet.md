
```bash
#!/bin/bash
#
# Bash must have been compiled with this ability: --enable-net-redirections
# The device files below do not actually exist.
# Use /dev/udp for UDP sockets

exec 3<>/dev/tcp/host/port

# Write to the socket as with any file descriptor
echo "Write this to the socket" >&3

# Read from the socket as with any file descriptor
cat <&3
```
