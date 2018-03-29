--
--------------------------------------------------------------------------------
--         File:  cuid.lua
--
--        Usage:  require("cuid")
--
--  Description:  CUID generator for Lua.
--
--      Options:  ---
-- Requirements:  ---
--         Bugs:  ---
--        Notes:  ---
--       Author:  Marco Aurélio da Silva (marcoonroad), <marcoonroad@gmail.com>
-- Organization:  ---
--      Version:  0.2
--      Created:  23-03-2018
--     Revision:  ---
--------------------------------------------------------------------------------
--

local export = { }

local CUID_PREFIX     = "c"
local FINGERPRINT     = os.getenv ("LUA_CUID_FINGERPRINT")
local counter         = 0
local BLOCK_SIZE      = 4
local DISCRETE_VALUES = 1679616 -- 36 ^ BLOCK_SIZE --
local LOADED_TIME     = os.time ( )

-- helper functions ---------------------------------
local function to_hex (number)
	return string.format ("%x", math.floor (number))
end

local function pad (number, size)
	local text   = string.format ("000000000%s", tostring (number))
	local length = string.len (text)

	return string.sub (text, (length - size) + 1)
end

local function safe_counter ( )
	counter = counter < DISCRETE_VALUES and counter or 0
	counter = counter + 1

	return counter - 1
end

local function random_uniform (limit)
	return math.random (1, limit)
end

local function random_block ( )
	local random = random_uniform (DISCRETE_VALUES)

	return pad (to_hex (random), BLOCK_SIZE)
end

local function fingerprint_sum (text)
	local sum    = 0
	local length = string.len (text) + 1 -- avoids div by zero --

	for letter in string.gmatch (text, ".") do
		sum = sum + string.byte (letter)
	end

	return sum / length
end

local function fingerprint ( )
	if FINGERPRINT then
		return pad (FINGERPRINT, BLOCK_SIZE)
	end

	local executable = os.getenv ("_")        or ""
	local hostname   = os.getenv ("HOSTNAME") or ""
	local user       = os.getenv ("USER")     or ""
	local directory  = os.getenv ("PWD")      or ""

	local first  = fingerprint_sum (executable)
	local second = fingerprint_sum (hostname)
	local third  = fingerprint_sum (user)
	local fourth = LOADED_TIME
	local fifth  = fingerprint_sum (directory)
	local sum    = (first + second + third + fourth + fifth) / 5

	return pad (to_hex (sum), BLOCK_SIZE)
end

-- private API --------------------------------------
function export.__set_fingerprint (value)
	FINGERPRINT = value
end

function export.__structure( )
	local timestamp = pad (to_hex (os.time ( )), BLOCK_SIZE * 2)
	local count     = pad (to_hex (safe_counter ( )), BLOCK_SIZE)
	local print     = fingerprint ( )
	local random    = random_block ( ) .. random_block ( )

	return {
		prefix      = CUID_PREFIX,
		timestamp   = timestamp,
		counter     = count,
		fingerprint = print,
		random      = random,
	}
end

-- public API ----------------------------------------------------
function export.generate ( )
	local result = export.__structure ( )

	return table.concat {
		result.prefix,
		result.timestamp,
		result.counter,
		result.fingerprint,
		result.random
	}
end

return export

-- END --
