-include .env
.PHONY: all build dev test clean install snapshot format

all: clean build

build:
	@echo "BUILDING..."
	@forge build

dev:
	@echo "WATCHING BUILD..."
	@forge build --watch

# clean the repo
clean :; @forge clean
# install dependencies
install :; @forge install
# test
test :; @forge test
fork-test :; @forge test $(NETWORK_ARGS)
snapshot:; @forge snapshot
format:; @forge fmt
update:; @forge update

NETWORK_ARGS := --fork-url http://localhost:8545
NETWORK_ARGS_SCRIPT := --rpc-url http://localhost:8545 --private-key $(PRIVATE_KEY) --broadcast