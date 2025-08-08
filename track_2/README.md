Flask App Deployment with Kubernetes (k3s) and Jenkins CI/CD
Technical Overview
This project implements a complete infrastructure automation solution deploying a Flask application on a lightweight Kubernetes cluster (k3s) with Jenkins CI/CD pipeline integration. The system is provisioned using Ansible and managed through Helm charts.

Core Components
1. Infrastructure Provisioning
Ansible Playbook (playbook.yaml):

Installs Docker CE and configures permissions

Deploys k3s (lightweight Kubernetes distribution)

Sets up Helm v3.14.4 package manager

Creates Kubernetes namespaces and RBAC rules

Configures Jenkins master and agent containers

2. Kubernetes Deployment
Helm Chart (flask-app-chart/):

Deployment with configurable replicas

Service (NodePort type)

Ingress with nginx controller

Horizontal Pod Autoscaler configuration

Resource limits and requests

Liveness/Readiness probes

3. CI/CD Pipeline
Jenkins Infrastructure:

Master container (jenkins/jenkins:latest)

Agent container (jenkins/inbound-agent:latest)

Shared Docker network (circus_network 192.168.50.0/24)

Persistent volume for agent workspace

Technical Specifications
Networking
Docker bridge network: circus_network (192.168.50.0/24)

Jenkins Master: 192.168.50.7

Jenkins Agent: 192.168.50.8

Service NodePort: 30562 (configurable)

Ingress host: formazionesou.local

Kubernetes Configuration
Namespace: formazione-sou

ServiceAccount: cluster-reader with limited RBAC

k3s config file permissions: 666 (for demo purposes)

Application Details
Flask app image: anmedyns/my_app:latest

Container port: 321

Service port: 80

Health checks: HTTP GET on /

Validation System
export.sh script verifies deployment contains:

Liveness/Readiness probes

Resource limits/requests

Exports deployment manifest on success

Dependencies
Python packages: See requirements.txt

System packages: Docker CE, k3s, Helm, Python3-pip

Kubernetes versions: v1.21+ (compatible with k3s)

Helm charts: API version v2
