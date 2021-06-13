.PHONY: build
uname := $(shell uname | tr 'A-Z' 'a-z')

build: ./bin/ytt
	./scripts/build.sh minecraft
	./scripts/build.sh budget

./bin/ytt:
	curl -L https://github.com/vmware-tanzu/carvel-ytt/releases/download/v0.34.0/ytt-${uname}-amd64 -o ./bin/ytt; chmod +x ./bin/ytt
