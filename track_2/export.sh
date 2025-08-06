#!/bin/bash

# Verifica presenza dei probes e delle risorse
if kubectl get deployment flask-app -n formazione-sou -o yaml | grep -q "livenessProbe:" && \
   kubectl get deployment flask-app -n formazione-sou -o yaml | grep -q "readinessProbe:" && \
   kubectl get deployment flask-app -n formazione-sou -o yaml | grep -q "limits:" && \
   kubectl get deployment flask-app -n formazione-sou -o yaml | grep -q "requests:"
then
    echo -e "\e[32m––– OK: the export is located in $HOME/export-flask-app.yaml\e[0m"
    kubectl get deployment  flask-app -n formazione-sou -o yaml >  /home/vagrant/export-flask-app.yaml
    exit 0
else
    echo -e "\e[31m––– ERROR: some parameters are missing –––\e[0m"
    exit 1
fi