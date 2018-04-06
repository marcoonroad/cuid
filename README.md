# CUID

CUID generator for Lua.

[![Build Status](https://travis-ci.org/marcoonroad/cuid.svg?branch=master)](https://travis-ci.org/marcoonroad/cuid)
[![Coverage Status](https://coveralls.io/repos/github/marcoonroad/cuid/badge.svg?branch=master)](https://coveralls.io/github/marcoonroad/cuid?branch=master)

For more information, see: http://usecuid.org

### Installation

If available on LuaRocks:

```
$ luarocks --local install cuid
```

Otherwise, you could install through this root project directory:

```
$ luarocks --local make
```

### Usage

To load this library, just type:

```lua
local cuid = require ("cuid")
```

Once loaded, you can generate fresh CUIDs through:

```lua
local id = cuid.generate ( )
```

As an example of CUID, we have `c00p6qup20000ckkzslahp5pn`, where:

- `c` is the CUID prefix (so it's a valid variable).
- `00p6qup2` is a timestamp/continuous number.
- `0000` is the internal sequential counter.
- `ckkz` is the machine/host fingerprint.
- `slahp5pn` are pseudo-random numbers.

### Configuration

You could as well set a custom fingerprint for CUID generation
by an environment variable. This environment variable is called
`LUA_CUID_FINGERPRINT`.

Whenever the `cuid` library is loaded, it will lookup such
environment variable to generate a fingerprint if it is
indeed defined.

### Remarks

Pull requests and issues are welcome! Happy hacking!
