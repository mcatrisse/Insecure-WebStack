# Insecure Web Server Deployment

This repo contains a script to deploy an insecure webserver stack:
- nginx (credentials.txt indexed)
- mysql (Root user is open + default root/root)
- FTP (vsftp) (https://nvd.nist.gov/vuln/detail/CVE-2011-2523)
    - POC -> (https://gopikrish1792.medium.com/installing-exploiting-vulnerable-ftp-service-on-ubuntu-17ac76c9561a)
    - Source -> (https://github.com/nikdubois/vsftpd-2.3.4-infected)

# Run the Script

```bash
cd /home/root
apt install -y curl
curl -s https://raw.githubusercontent.com/TheMatrix97/Insecure-WebStack/refs/tags/1.0.0/script.sh | bash
```

# Part 2

Run the script
```bash
curl -s https://raw.githubusercontent.com/TheMatrix97/Insecure-WebStack/refs/tags/2.0.0/script_part2.sh | bash
```


# Docker

```bash
sudo docker build -t insecure-stack:latest .
sudo docker network create --subnet 172.6.0.0/16 pentest
sudo docker run -d \
  --name insecure-stack \
  --network pentest \
  --ip 172.6.6.15 \
  insecure-stack:latest
```

## Cleanup

```bash
sudo docker rm -f insecure-stack
sudo docker network rm pentest
```