# All possible Lua version to suuport.
SUPPORTED_LUA = lua lua-5.1 lua-5.2 lua-5.3 lua-5.4 luajit

# Search exec in the PATH and return as list
FOUND_EXECS := $(foreach exec,$(SUPPORTED_LUA),\
		$(if $(shell which $(exec) 2> /dev/null),$(exec),))

# Get first found exec and use it.
LUA_EXEC := $(firstword $(FOUND_EXECS))
LUA_EXEC := $(if $(LUA_EXEC),$(LUA_EXEC),$(error 'No Lua executable found. Please install any of the following Lua versions: $(SUPPORTED_LUA)'))

# Get lua version.
LUA_VERSION != $(LUA_EXEC) -e 'io.write(_VERSION:sub(5))'

# These can be overriden from the shell.
# For example:
#   PREFIX=/etc/opt make install
#   BIN=/etc/bin make install
#   SHARE=/etc/share make install
PREFIX ?= /usr/local
BIN ?= ${PREFIX}/bin
SHARE ?= ${PREFIX}/share/lua/$(LUA_VERSION)/

all:
		@echo "Possible make targets are: test, install, uninstall, sym-install"

sym-install:
		@echo "Symlinking Laura"
		ln -s $(shell pwd)/bin/laura $(BIN)/laura

install:
		@echo "Installing Laura exec file"
		cp ./bin/laura $(BIN)/
		chmod 0755 $(BIN)/laura

		@echo "Installing Laura shared files"
		mkdir -pv $(SHARE)/laura/lib
		cp -r $(shell pwd)/lib $(SHARE)/laura
		cp -r $(shell pwd)/*.lua $(SHARE)/laura
		find $(SHARE)/laura -type f -exec chmod 644 {} \;
		@echo "Done"

uninstall:
		@echo "Uninstalling Laura exec file and shared files"
		rm -rf $(BIN)/laura $(SHARE)/laura
		@echo "Done"
