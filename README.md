# Laura - unit-testing framework for Lua

<p align="center">
<a href="https://github.com/dknight/laura/actions/workflows/tests.yml"><img src="https://github.com/dknight/laura/actions/workflows/tests.yml/badge.svg" alt="Tests"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: ISC"></a>
<a href="https://luarocks.org/modules/dknight/laura"><img src="https://img.shields.io/luarocks/v/dknight/laura" alt="LuaRocks"></a>
</p>

Laura is a lightweight unit-testing framework for Lua with simplicity in mind.
The framework has no dependencies and works with Lua versions 5.1—5.4 and
LuaJIT.

- **Lightweight**
- **Easy to install and launch**
- **No Dependencies**
- **Understandable Feedback**
- **Fast**

[Complete documentation\_](https://www.whoop.ee/laura/)

## Getting started

### Install

There are several ways to install.

#### LuaRocks

```sh
luarocks install laura
```

...or use the tree in the user's home directory.

```sh
luarocks --local install laura
```

#### Makefile

Using the `make` utility to install.

Clone the source code.

```sh
git clone https://github.com/dknight/laura.git
```

Run `make`

```sh
make install
```

There are variables that can be set with `make`.

- `PREFIX` - basic installation prefix for the module (default `/usr/local`);
- `BINDIR` - use the binary path in the file system tree (default `${PREFIX}/bin`);
- `LIBDIR` - where to put the shared libraries (default `${PREFIX}/share/lua/${LUA_VERSION}`)

```sh
PREFIX=/opt/lua/libs BINDIR=/opt/bin LIBDIR=/opt/share make install
```

## Writing tests

Writing test is pretty simple and straightforward.

```lua
local describe = require("laura.describe")
local it = require("laura.it") --
local expect = require("laura.expect") --

describe("my test case", function()
	it("should be equal to three", function()
		expect(1 + 2).toEqual(3)
	end)
end)
```

## Running tests

By default, Laura looks for files with pattern `*_test.lua` in the given directory. Current directory is the default value.

```sh
laura [test_dir]
```

## Configuration

There are the [options](https://github.com/dknight/laura/blob/main/src/Config.lua) that can be customized.
Check more options on the [documentation page](https://www.whoop.ee/laura/).

Options can be set in any \*.lua file that returned a module and specified with flag.

```sh
luara -c <path_to_config.lua> [test_dir]
```

## Documentation

Read the complete documentation on the [external website](https://www.whoop.ee/laura/).

## What is not included yet

- Code coverage.

## Compatibility Notes

No UTF-8 support in Lua before 5.3; to add support for UTF8, please install

[an extra UTF-8 module](https://github.com/starwing/luautf8).

## Contribution

Any help is appreciated. Found a bug, typo, inaccuracy, etc.? Please do
not hesitate and make a pull request or issue.

## License

MIT 2024
