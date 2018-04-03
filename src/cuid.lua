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
--      Version:  0.3
--      Created:  23-03-2018
--     Revision:  ---
--------------------------------------------------------------------------------
--

local export = { }

local CUID_PREFIX     = "c"
local counter         = 0
local BLOCK_SIZE      = 4
local DISCRETE_VALUES = 1679616 -- 36 ^ BLOCK_SIZE --
local LOADED_TIME     = os.time ( )
local EXECUTABLE      = os.getenv ("_")        or ""
local HOSTNAME        = os.getenv ("HOSTNAME") or ""
local USER            = os.getenv ("USER")     or ""
local DIRECTORY       = os.getenv ("PWD")      or ""

local CUSTOM_FINGERPRINT = os.getenv ("LUA_CUID_FINGERPRINT")

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
	return math.random (0, limit - 1)
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

local function default_fingerprint ( )
	local first  = fingerprint_sum (EXECUTABLE)
	local second = fingerprint_sum (HOSTNAME)
	local third  = fingerprint_sum (USER)
	local fourth = LOADED_TIME
	local fifth  = fingerprint_sum (DIRECTORY)
	local sum    = (first + second + third + fourth + fifth) / 5

	return pad (to_hex (sum), BLOCK_SIZE)
end

local DEFAULT_FINGERPRINT = (function ( )
	if CUSTOM_FINGERPRINT then
		local sum = fingerprint_sum (CUSTOM_FINGERPRINT)

		CUSTOM_FINGERPRINT = nil -- so it won't be used anymore --

		return pad (to_hex (sum), BLOCK_SIZE)
	end

	return default_fingerprint ( )
end) ( )

local function fingerprint ( )
	-- employs memoization --
	if CUSTOM_FINGERPRINT then
		local sum = fingerprint_sum (CUSTOM_FINGERPRINT)

		CUSTOM_FINGERPRINT  = nil
		DEFAULT_FINGERPRINT = pad (to_hex (sum), BLOCK_SIZE)
	end

	return DEFAULT_FINGERPRINT
end

local function pad_from_hex (value, size)
	return pad (to_hex (value), size)
end

-- private API --------------------------------------
function export.__set_fingerprint (value)
	DEFAULT_FINGERPRINT = nil
	CUSTOM_FINGERPRINT  = value
end

function export.__reset_fingerprint ( )
	CUSTOM_FINGERPRINT  = nil
	DEFAULT_FINGERPRINT = default_fingerprint ( )
end

function export.__structure( )
	local timestamp = pad_from_hex (os.time ( ),      BLOCK_SIZE * 2)
	local count     = pad_from_hex (safe_counter ( ), BLOCK_SIZE)
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

	return result.prefix ..
		result.timestamp ..
		result.counter ..
		result.fingerprint ..
		result.random
end

return export

-- END --
