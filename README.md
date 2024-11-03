# Laura &ndash; unit-testing framework for Lua

<div align="center">
  <br>
  <picture>
  	<img src="https://raw.githubusercontent.com/dknight/laura/refs/heads/main/misc/pix.svg?raw=true" width="256" height="256" alt="Laura Testing Framework">
  </picture>
  <br>
</div>

<p align="center">
<a href="https://github.com/dknight/laura/actions/workflows/tests.yml"><img src="https://github.com/dknight/laura/actions/workflows/tests.yml/badge.svg" alt="Tests"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
<a href="https://luarocks.org/modules/dknight/laura"><img src="https://img.shields.io/luarocks/v/dknight/laura?color=be2865" alt="LuaRocks"></a>
</p>

<p align="center">
Laura 👧🏻 is a lightweight unit-testing framework for Lua with simplicity in mind.
The framework has no dependencies and is compatible with Lua versions 5.1&mdash;5.4 and LuaJIT.
</p>

## Features

- **Lightweight and minimalist**
- **Easy to install and use**
- **No Dependencies**
- **Understandable, human-readable feedback**
- **Compatible with any Lua 5.1+ version and LuaJIT**

📚 [Complete documentation](https://www.whoop.ee/post/laura-unit-testing-framework-for-lua.html)

## Getting started

### Install

There are several ways to install: LuaRocks, Make utility, and manual installation.

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

- `PREFIX`: basic installation prefix for the module (default `/usr/local`);
- `BINDIR`: use the binary path in the file system tree (default `${PREFIX}/bin`);
- `LIBDIR`: where to put the shared libraries (default `${PREFIX}/share/lua/${LUA_VERSION}`)

Consider:

```sh
PREFIX=/opt/lua/libs BINDIR=/opt/bin LIBDIR=/opt/share make install
```

#### Manual installation

Just clone the repository and include the location to `LUA_PATH`
environment variable.

## Writing tests

Writing tests is pretty simple and straightforward.

```lua
local laura = require("laura")

local it = laura.it
local describe = laura.describe
local expect = laura.expect

describe("my test case", function()
	it("should be equal to three", function()
		expect(1 + 2).toEqual(3)
	end)
end)
```

### Skipping tests

There is a possibility to skip the test case or suite using the `skip` method.
Skipped tests won't run and will be reported as **[SKIPPED]**. Please note
that there is a `:` colon. If you mark a suite as skipped, all its children will
also be skipped.

```lua
local laura = require("laura")

local it = laura.it
local describe = laura.describe
local expect = laura.expect

describe:skip("skip", function()
	it("should be skipped", function()
		expect(1 + 2).toEqual(3)
	end)
end)
```

### Only tests

Like skipped tests, mark tests with `only`; only marked tests will run;
others will be ignored, useful for debugging.

```lua
local laura = require("laura")

local it = laura.it
local describe = laura.describe
local expect = laura.expect

describe:only("only suite", function()
	it("should be three", function()
		expect(1 + 2).toEqual(3)
	end)
end)
```

## Running tests

### Using Command Line Client

By default, Laura looks for files with pattern `*_test.lua` in the given directory. Current directory is the default value.

```sh
laura [test_dir]
```

### Using API

Consider example:

```lua
local laura = require("laura")
local TextReporter = require("laura.reporters.text")

local it = laura.it
local describe = laura.describe
local expect = laura.expect
local Runner = laura.Runner

describe("my test case", function()
	it("should be equal to three", function()
		expect(1 + 2).toEqual(3)
	end)
end)

local runner = Runner:new()
local results = runner:runTests()
local reporter = TextReporter:new(results)
reporter:report()
runner:done()
```

## Configuration

There are the [options](https://github.com/dknight/laura/blob/main/src/Config.lua) that can be customized.
Check more options on the [documentation page](https://www.whoop.ee/post/laura-unit-testing-framework-for-lua.html).

Options can be set in any \*.lua file that returns a module and specified with a flag.

```sh
laura -c <path_to_config.lua> [test_dir]
```

Another way to create [`.laurarc`](https://github.com/dknight/laura/blob/main/.laurarc)
file in your project directory and setup preferences in the same format
as in the configuration file.

Also, there are ["private" configuration fields](https://github.com/dknight/laura/blob/main/src/laura/Config.lua), which are not recommended to change, unless you know that you know what you are doing.

# Code coverage

Code coverage can be enabled in `.laurarc` configuration file. Or if you are
using CLI flag `--coverage`. There are extra coverage reporters can be used,
like: terminal, html, csv, etc. Check [configuration file](https://github.com/dknight/laura/blob/main/src/laura/Config.lua) source.

## Documentation

Read the complete documentation on the [external website](https://www.whoop.ee/post/laura-unit-testing-framework-for-lua.html).

## Known issues

**Code coverage** is yet to be finalized. It might have the inaccuracies.

## Credits

Original picture by [lumeish](https://lumeish.itch.io/), used under
[Creative Commons Attribution v4.0 International](https://itch.io/game-assets/assets-cc4-by) license.

Coverage line scanner is modified algorithm based on [lunarmodules/luacov](https://github.com/lunarmodules/luacov), published under
[MIT](https://opensource.org/license/MIT) license.

## Contribution

Any help is appreciated. Found a bug, typo, inaccuracy, etc.? Please do
not hesitate to create [a pull request](https://github.com/dknight/laura/pulls) or submit an [issue](https://github.com/dknight/laura/issues).

## License

MIT 2024
