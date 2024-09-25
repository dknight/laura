# All possible Lua version to suuport.
SUPPORTED_VERSIONS = lua lua-5.1 lua-5.2 lua-5.3 lua-5.4 luajit

# Search exec in the PATH and return as list
FOUND_EXECS := $(foreach exec,$(SUPPORTED_VERSIONS),\
		$(if $(shell which $(exec) 2> /dev/null),$(exec),))

# Get first found exec and use it.
LUA_EXEC := $(firstword $(FOUND_EXECS))
LUA_EXEC := $(if $(LUA_EXEC),$(LUA_EXEC),$(error 'No Lua executable found. Please install any of the following Lua versions: $(SUPPORTED_VERSIONS)'))

# Get lua version.
LUA_VERSION != $(LUA_EXEC) -e 'io.write(_VERSION:sub(5))'

# These can be overriden from the shell.
# For example:
#   PREFIX_PATH=/etc/opt make install
#   BIN=/etc/bin make install
#   SHARE=/etc/share make install
PREFIX_PATH ?= /usr/local
BIN_PATH ?= ${PREFIX_PATH}/bin
LUA_SHARE_PATH ?= ${PREFIX_PATH}/share/lua/$(LUA_VERSION)/

all:
		@echo "Possible make targets are: test, install, uninstall, sym-install"

sym-install:
		@echo "Symlinking Laura"
		ln -s $(shell pwd)/bin/laura $(BIN_PATH)/laura

install:
		@echo "Installing Laura exec file"
		cp ./bin/laura $(BIN_PATH)/
		chmod 0755 $(BIN_PATH)/laura

		@echo "Installing Laura shared files"
		mkdir -pv $(LUA_SHARE_PATH)/laura/src
		cp -r $(shell pwd)/src $(LUA_SHARE_PATH)/laura
		cp -r $(shell pwd)/*.lua $(LUA_SHARE_PATH)/laura
		find $(LUA_SHARE_PATH)/laura -type f -exec chmod 644 {} \;
		@echo "Done"

uninstall:
		@echo "Uninstalling Laura exec file and shared files"
		rm -rf $(BIN_PATH)/laura $(LUA_SHARE_PATH)/laura
		@echo "Done"

test:
		@echo "Running tests"
		$(LUA_EXEC) -v
		$(LUA_EXEC) ./bin/laura tests

lint:
		luacheck --no-self .