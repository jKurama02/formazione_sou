# Basic Port Scanner with Vagrant

A simple project to test port scanning between two Debian VMs using netcat.

## Setup
1. Clone this repository
2. Run `vagrant up` to create the VMs
3. Connect to a VM with `vagrant ssh debian1` or `vagrant ssh debian2`

## How to Use the Scanner
Inside either VM:

chmod +x scan.sh
./scan.sh

The script will ask for:
1. Target IP (use 192.168.56.10 or 192.168.56.20)
2. Starting port number
3. Ending port number

## VM Details
- Two Debian 11 VMs
- Private network IPs:
  - debian1: 192.168.56.10
  - debian2: 192.168.56.20
- Netcat pre-installed
- Port scanner script in /home/vagrant/

  hi from SOU ^______^

