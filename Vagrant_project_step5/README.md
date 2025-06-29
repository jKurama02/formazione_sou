Hi everyone 👋, 
this proggetto has allowed me to develop more confidence with the Vagrant software ( written in Ruby ).

💻 Basically it's a method to automate the development of two VM (virtual machines), with the corresponding settings.
So that the machine with Debian can act as an Apache server, having modified the index.html file in the “/var/www/html/” directory.
The other machine's only task is to verify that it is possible to make a GET request via the “curl http://192.168.56.20” command , since the machines were set up on the same network.

# to get a complete view of what happens before, after and during the exchange of information between the two machines, use “curl -v” (verbose). It will also allow you to see the unfolding of the "Three-Way HandShake".
