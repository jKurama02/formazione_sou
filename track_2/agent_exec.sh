#!/bin/bash

######################  THIS IS A BONUS TRACK ######################
# This script automates the setup of a Jenkins agent by:
# 1. Obtaining a Jenkins crumb for CSRF protection
# 2. Generating an API token for authentication
# 3. Creating a new Jenkins node (agent)
# 4. Retrieving the agent secret and starting the Jenkins agent

# You can parameterize the following variables
# - JENKINS_URL
# - USERNAME
# - PASSWORD
# - NODE_NAME
# - TOKEN_NAME

# not needed ---jq--- ,  is not used

# Configuration
JENKINS_URL="http://192.168.50.7:8080"
USERNAME="admin"
PASSWORD="admin"
COOKIE_FILE="cookies.txt"
NODE_NAME="Pino"
TOKEN_NAME="myToken"

# Clean previous files
rm -f "$COOKIE_FILE" 2>/dev/null

# Step 1: Get Jenkins Crumb
echo "Getting Jenkins Crumb..."
CRUMB_RESPONSE=$(curl -u "$USERNAME:$PASSWORD" -c "$COOKIE_FILE" -s \
  "$JENKINS_URL/crumbIssuer/api/json")

# Extract crumb using grep and sed instead of jq
CRUMB=$(echo "$CRUMB_RESPONSE" | grep -o '"crumb":"[^"]*"' | sed 's/"crumb":"//g' | sed 's/"//g')

if [ -z "$CRUMB" ]; then
    echo "Error: Cannot get crumb"
    rm -f "$COOKIE_FILE" 2>/dev/null
    exit 1
fi

echo "Crumb: $CRUMB"

# Step 2: Generate API Token
echo "Generating API Token..."
TOKEN_RESPONSE=$(curl -u "$USERNAME:$PASSWORD" -b "$COOKIE_FILE" \
  -H "Jenkins-Crumb:$CRUMB" -X POST \
  --data-urlencode "newTokenName=$TOKEN_NAME" \
  -s "$JENKINS_URL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken")

# Extract token using grep and sed instead of jq
TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"tokenValue":"[^"]*"' | sed 's/"tokenValue":"//g' | sed 's/"//g')

if [ -z "$TOKEN" ]; then
    echo "Error: Cannot generate token"
    echo "Response: $TOKEN_RESPONSE"
    rm -f "$COOKIE_FILE" 2>/dev/null
    exit 1
fi

echo "API Token: $TOKEN"

# Step 3: Create Jenkins Node
echo "Creating node: $NODE_NAME"
CREATE_RESPONSE=$(curl -u "$USERNAME:$TOKEN" -X POST \
  -H "Jenkins-Crumb: $CRUMB" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data "json={\"name\": \"$NODE_NAME\", \"nodeDescription\": \"\", \"numExecutors\": \"1\", \"remoteFS\": \"\$/home/jenkins/agent\", \"labelString\": \"\", \"mode\": \"EXCLUSIVE\"}" \
  -s "$JENKINS_URL/computer/doCreateItem?name=$NODE_NAME&type=hudson.slaves.DumbSlave")

if echo "$CREATE_RESPONSE" | grep -q "success"; then
    echo "Node $NODE_NAME created successfully!"
else
    echo "Error creating node:"
    echo "$CREATE_RESPONSE"
fi

# Step 4: Get agent secret and start agent
echo "Getting agent secret..."
JNLP_RESPONSE=$(curl -u "$USERNAME:$TOKEN" -s \
  "$JENKINS_URL/computer/$NODE_NAME/slave-agent.jnlp")

# Extract secret using grep and sed
SECRET=$(echo "$JNLP_RESPONSE" | grep -o '<argument>[a-f0-9]\{64\}</argument>' | sed 's/<[^>]*>//g')

if [ -z "$SECRET" ]; then
    echo "Error: Cannot get agent secret"
    echo "JNLP Response: $JNLP_RESPONSE"
    rm -f "$COOKIE_FILE" 2>/dev/null
    exit 1
fi

echo "Agent secret: $SECRET"

# Download and start Jenkins agent
echo "Downloading Jenkins agent..."
curl -sO "$JENKINS_URL/jnlpJars/agent.jar"

echo "Starting Jenkins agent..."
java -jar agent.jar -url "$JENKINS_URL/" -secret "$SECRET" -name "$NODE_NAME" -webSocket -workDir "/home/jenkins/agent"

# Export environment variables
export JENKINS_URL="$JENKINS_URL"
export JENKINS_USER="$USERNAME"
export JENKINS_CRUMB="$CRUMB"
export JENKINS_TOKEN="$TOKEN"
export NODE_NAME="$NODE_NAME"
export JENKINS_SECRET="$SECRET"

echo ""
echo "Environment variables exported:"
echo "JENKINS_URL=$JENKINS_URL"
echo "JENKINS_USER=$JENKINS_USER"
echo "JENKINS_CRUMB=$JENKINS_CRUMB"
echo "JENKINS_TOKEN=$JENKINS_TOKEN"
echo "NODE_NAME=$NODE_NAME"
echo "JENKINS_SECRET=$SECRET"

# Cleanup
rm -f "$COOKIE_FILE" 2>/dev/null
echo "Script completed!"