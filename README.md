### MacOS Guide

Traefik configuration for local Docker development stacks.

Medium Article: https://medium.com/soulweb-academy/docker-local-dev-stack-with-traefik-https-dnsmasq-locally-trusted-certificate-for-ubuntu-20-04-5f036c9af83d

## What are we using
- Traefik v2.0
- Portainer
- Whoami
- Dnsmasq
- Mkcert

## Requirements
- Docker
- Docker Compose
- Homebrew

## Create docker 'web' network
docker network create web

## Update resolv.conf
ls -lh /etc/resolv.conf
sudo rm /etc/resolv.conf
sudo touch /etc/resolv.conf
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'

## Install DNSmasq
brew install dnsmasq
brew link dnsmasq

## Create DNSmasq conf
sudo echo 'address=/.localdev/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
sudo mkdir -v $(brew --prefix)/etc/resolver && sudo bash -c 'echo "nameserver 127.0.0.1" > $(brew --prefix)/etc/resolver/localdev'

## Restart DNSmasq
sudo brew services restart dnsmasq

## Install Mkcert
brew install mkcert
brew install nss
mkcert -install

## Generate locally-trusted certificate
mkcert -key-file ./certs/key.pem -cert-file ./certs/cert.pem localdev 'docker.localdev' '*.docker.localdev'
mkcert -key-file ./certs/key.misbrico.pem -cert-file ./certs/cert.misbrico.pem 'misbrico.docker.localdev' '*.misbrico.docker.localdev'
