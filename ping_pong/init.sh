#!/bin/bash 

vagrant up
echo "____VM_UP_____"
vagrant ssh debian -c "sudo docker pull ealen/echo-server"
vagrant ssh debian2 -c "sudo docker pull ealen/echo-server"
a=0
while true;
do
    echo "____Start docker Debian _____"
    if((a < 1)); then
        vagrant ssh debian -c "sudo docker run -d -p 3000:80 ealen/echo-server"
        ((a++))
    else
        vagrant ssh debian -c 'C_id=$(sudo docker ps -q); sudo docker start "$C_id";'
    fi
    i=0
    echo -n "Waiting "
    while ((i < 59))
    do
        echo -n '.'
        sleep 1
        ((i++))
    done;
    vagrant ssh debian -c 'C_id=$(sudo docker ps -q); sudo docker stop "$C_id";'
    echo "____Finish docker Debian _____"
    echo "____Start docker Debian 2_____"
    if((a < 2)); then
        vagrant ssh debian -c "sudo docker run -d -p 3000:80 ealen/echo-server"
        ((a++))
    else
        vagrant ssh debian -c 'C_id=$(sudo docker ps -q); sudo docker start "$C_id";'
    fi
    i=0
    echo -n "Waiting "
    while ((i < 59))
    do
        echo -n '.'
        sleep 1
        ((i++))
    done;
    vagrant ssh debian2 -c 'C_id=$(sudo docker ps -q); sudo docker stop "$C_id";'
    echo "____Finish docker Debian 2_____"
done;


