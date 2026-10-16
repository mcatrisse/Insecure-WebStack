#!/bin/sh

# Add Docker's official GPG key:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian trixie stable" | sudo tee /etc/apt/sources.list.d/docker.list
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Update and install
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Config Docker
sudo usermod -aG docker $USER
sudo systemctl enable docker --now
newgrp docker