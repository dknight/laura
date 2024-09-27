# All possible Lua version to suuport.
SUPPORTED_VERSIONS = lua lua-5.1 lua-5.2 lua-5.3 lua-5.4 luajit

# Search exec in the PATH and return as list
FOUND_EXECS := $(foreach exec,$(SUPPORTED_VERSIONS),\
		$(if $(shell which $(exec) 2> /dev/null),$(exec),))

# Get first found exec and use it.
LUA := $(firstword $(FOUND_EXECS))
LUA := $(if $(LUA),$(LUA),$(error 'No Lua executable found. Please install any of the following Lua versions: $(SUPPORTED_VERSIONS)'))

# Get lua version.
LUA_VERSION != $(LUA) -e 'io.write(_VERSION:match("%d+%.%d+"))'

# These can be overriden from the shell.
# For example:
#   PREFIX=/usr/local make install
#   BINDIR=/usr/local/bin make install
#   LIBDIR=/usr/local/share/lua/5.4 make install
PREFIX ?= /usr/local
BINDIR ?= ${PREFIX}/bin
LIBDIR ?= ${PREFIX}/share/lua/${LUA_VERSION}

default:
		@echo "Possible make targets are: test, install, uninstall"

install:
		@echo "Installing Laura executable file"
		cp ./bin/laura $(BINDIR)/
		chmod 0755 $(BINDIR)/laura

		@echo "Installing Laura shared files"
		mkdir -pv $(LIBDIR)/laura
		cp -r $(shell pwd)/src/laura $(LIBDIR)
		find $(LIBDIR)/laura -type f -exec chmod 644 {} \;
		@echo "Done"

uninstall:
		@echo "Uninstalling Laura exec file and shared files"
		rm -rf $(BINDIR)/laura $(LIBDIR)/laura
		@echo "Done"

test:
		@echo "Running tests"
		$(LUA) -v
		$(LUA) ./bin/laura tests

lint:
		luacheck --no-self .