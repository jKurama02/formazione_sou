# Container Management Training

Automated container deployment with Ansible roles and Jenkins CI/CD integration.

## Project Overview

**Two-part architecture:**
- **Part 1**: Core infrastructure using Ansible roles (`start.yaml`)
- **Part 2**: Jenkins CI/CD setup with dedicated playbook (`jenkins/jenkins.yaml`)

### Part 1: Infrastructure Roles
- `registry_setup/` - Private Docker registry (port 5000)
- `container_builder/` - Build CentOS/Rocky9 images
- `container_runner/` - Deploy containers with SSH access

### Part 2: Jenkins Setup
- Custom Docker network (172.18.0.0/16)
- Internal registry at 172.18.0.2:5000
- Jenkins agent with Docker-in-Docker capability

## Usage

### 1. Generate SSH Keys
```bash
ssh-keygen -t rsa -b 4096 -f dockerfiles/id_key_genericuser -N ""
```

### 2. Run Infrastructure Roles
```bash
# Deploy core infrastructure (registry + containers)
ansible-playbook start.yaml

# Individual components
ansible-playbook start.yaml --tags registry
ansible-playbook start.yaml --tags build
ansible-playbook start.yaml --tags run
```

**Creates:**
- Registry: `localhost:5000`
- CentOS container: SSH port `2222`
- Rocky9 container: SSH port `2223`

### 3. Clean workingspace
```bash
# Stop and remove project containers
docker stop local-registry centos-ssh-running rocky9-ssh-running  2>/dev/null
docker rm local-registry centos-ssh-running rocky9-ssh-running  2>/dev/null

```

### 4. Run Jenkins Setup
```bash
# Deploy Jenkins infrastructure
ansible-playbook jenkins/jenkins.yaml --vault-password-file .vault_pass
```

### 4.1 Decrypt dockerfile/env.yaml
```bash
ansible-vault decrypt dockerfiles/env.yaml  --vault-password-file .vault_pass
```
### 4.2 Decrypt dockerfile/env.yaml
```bash
ansible-vault encrypt dockerfiles/env.yaml  --vault-password-file .vault_pass
```

**Creates:**
- Docker network `docker_registry`
- Internal registry at 172.18.0.2:5000
- Jenkins agent container (port 2224)
- Pre-configured with Ansible and Docker-in-Docker

**Jenkins agent capabilities:**
- Build and push images to internal registry
- Run Ansible playbooks
- SSH access for Jenkins master integration

## Project Structure

```
formazione_cm/
├── start.yaml                    # Part 1: Roles-based playbook
├── roles/
│   ├── registry_setup/           # Docker registry setup
│   ├── container_builder/        # Image building logic
│   └── container_runner/         # Container deployment
├── jenkins/
│   ├── jenkins.yaml              # Part 2: Jenkins playbook
│   └── jenkinsfile              # CI/CD pipeline
└── dockerfiles/
    ├── env.yaml                  # Environment variables
    ├── id_key_genericuser*       # SSH key pair
    ├── Dockerfile.centos         # CentOS image
    ├── Dockerfile.rocky9         # Rocky9 image
    └── Dockerfile.jenkins_agent  # Jenkins DinD agent
```

## Access

### SSH Connections
```bash
ssh -i dockerfiles/id_key_genericuser -p 2222 genericuser@localhost  # CentOS  # localhost is ipv6 in MacOs , try 127.0.0.1
ssh -i dockerfiles/id_key_genericuser -p 2223 genericuser@localhost  # Rocky9
ssh -i dockerfiles/id_key_genericuser -p 2224 jenkins@localhost      # Jenkins
```

### Registry Access
```bash
curl http://localhost:5000/v2/_catalog                    # External
curl http://172.18.0.2:5000/v2/_catalog                   # Internal network
```

## Jenkins Master Configuration

**Important**: The Jenkins master must be configured to run on the `docker_registry` network to properly communicate with the Jenkins agent and internal registry.

### Required Jenkins Master Setup
```bash
docker run -d \
  --name jenkins-master \
  --network docker_registry \
  --ip 172.18.0.5 \
  -p 8080:8080 \
  -p 50001:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Why this configuration is mandatory:**
- The Jenkins agent container runs on the `docker_registry` network (172.18.0.0/16)
- Internal registry is accessible at `172.18.0.2:5000` only from within this network
- Jenkins master needs to communicate with the agent on the same network segment
- Without this network configuration, Jenkins master cannot reach the agent or internal registry

**Network topology:**
- Jenkins Master: `172.18.0.5:8080` (web UI accessible via localhost:8080)
- Internal Registry: `172.18.0.2:5000`
- Jenkins Agent: `172.18.0.3:2224` (SSH access)