SHELL := /bin/bash
PREFIX ?= /usr/local
BIN=${PREFIX}/bin
SHARE=${PREFIX}/share

sym-install:
		@echo "Symlinking Laura"
		ln -s $(shell pwd)/bin/laura $(BIN)/laura

install:
		@echo "Installing Laura binary"
		cp ./bin/laura $(BIN)/
		chmod 0755 $(BIN)/laura

		@echo "Installing Laura assets"
		mkdir -pv $(SHARE)/laura/lib
		cp -r $(shell pwd)/lib $(SHARE)/laura/lib
		cp -r $(shell pwd)/*.lua $(SHARE)/laura
		find $(SHARE)/laura -type f -exec chmod 644 {} \;
		@echo "Done"

uninstall:
		@echo "Uninstalling Laura script and assets"
		rm -rf $(BIN)/laura $(SHARE)/laura
		@echo "Done"

test:
	@echo "Starting tests"
	$(BIN)/laura $(shell pwd)