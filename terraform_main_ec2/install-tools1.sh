#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y

# -------------------- Install Git --------------------
sudo apt install -y git

# -------------------- Install Java (for Jenkins) --------------------
sudo apt install -y openjdk-17-jdk

# -------------------- Install Jenkins --------------------
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -y
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# -------------------- Install Terraform --------------------
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o \
  /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee \
  /etc/apt/sources.list.d/hashicorp.list

sudo apt update -y
sudo apt install -y terraform

# -------------------- Install Maven --------------------
sudo apt install -y maven

# -------------------- Install kubectl --------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# -------------------- Install eksctl --------------------
curl --silent --location \
"https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
| tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

# -------------------- Install Helm --------------------
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | \
sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm

# -------------------- Install Docker --------------------
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add users to docker group
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins || true

# -------------------- Install Trivy --------------------
sudo apt install -y wget gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt update
sudo apt install -y trivy

# -------------------- Install SonarQube via Docker --------------------
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# -------------------- Install ArgoCD --------------------
kubectl create namespace argocd || true
kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# -------------------- Install Prometheus & Grafana --------------------
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace prometheus || true
helm install kube-prom-stack prometheus-community/kube-prometheus-stack -n prometheus

# -------------------- Install MariaDB --------------------
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo "Initialization script completed successfully."
