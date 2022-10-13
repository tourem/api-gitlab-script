nc -lk -p 5000 127.0.0.1 -e 'date'

The command starts a listener on localhost on port 5000 and prints the date command to any connected TCP client.

Can the second container connect to it?

Open a terminal in the second container with:

Now you can verify that the second container can connect to the network listener, but cannot see the nc process:

telnet localhost 5000
Connected to localhost
Sun Nov 29 00:57:37 UTC 2020
Connection closed by foreign host
