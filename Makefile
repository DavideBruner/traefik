include .env

default: up

.PHONY: up
up:
	docker-compose -f traefik.yml up -d

DOMAIN := echo ${DOCKER_BASE_URL} | cut -d "." -f2 -s || "localdev"

.PHONY: init
init:
	@docker network create web || true

	@echo 'Updating resolv.conf'
	@ls -lh /etc/resolv.conf
	@sudo rm /etc/resolv.conf
	@sudo touch /etc/resolv.conf
	@sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolv.conf'
	@sudo bash -c 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'

	@echo 'Installing dnsmasq'
	@brew install dnsmasq
	@brew link dnsmasq

	@echo 'Generating dnsmasq conf'
	@sudo echo 'address=/.${DOMAIN}/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
	@sudo mkdir -v $(brew --prefix)/etc/resolver && sudo bash -c 'echo "nameserver 127.0.0.1" > $(brew --prefix)/etc/resolver/${DOMAIN}'
	@sudo brew services restart dnsmasq

	@echo 'Installing Mkcert'
	@brew install mkcert
	@brew install nss
	@mkcert -install

	@echo 'Generating locally-trusted certificate'
	@mkcert -key-file ./certs/key.pem -cert-file ./certs/cert.pem ${DOMAIN} ${DOCKER_BASE_URL} '*.${DOCKER_BASE_URL}'
	@echo "Execute the command \033[4mmkcert -key-file ./certs/example.key.pem -cert-file ./certs/example.cert.pem 'example' 'site.example' '*.site.example'\033[0m to generate a custom certificate"