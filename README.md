# CUID

CUID generator for Lua.

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

### Configuration

You could as well set a custom fingerprint for CUID generation
by an environment variable. This environment variable is called
`LUA_CUID_FINGERPRINT`.

Whenever the `cuid` library is loaded, it will lookup such
environment variable to generate a fingerprint if it is
indeed defined.

### Remarks

Pull requests and issues are welcome! Happy hacking!

