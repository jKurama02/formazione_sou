#!/bin/bash

# "Scrivere uno script che accetti un argomento numerico e stampi la sequenze di numeri da 1 a quel numero con 
# l'indicazione se è pari o dispari. Controllare il corretto numero di argomenti passati allo script e 
# che l'argomento sia di tipo numerico, in caso contrario generare una condizione di errore."

if [ "$#" -ne 1 ]; then
    echo "Error: bad argument"
    exit 1
fi

if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    echo "Error: bad argument"
    exit 1
fi
i=0
while [ $i -le $1 ];
do
    if [ $((i % 2)) -eq 0 ]; then
        echo "$i is even"
    else
        echo "$i is odd"
    fi
    ((i++))
done;

