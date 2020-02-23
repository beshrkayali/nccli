.PHONY: format
format:
	nimfmt -i $(shell find . -type f -regex ".*\.nim")


.PHONY: 
build:
	nimble c -o:bin/nccli src/nccli.nim


.PHONY: install
install:
	nimble install -y && nccli


.PHONY: run
run: build
	./bin/nccli
