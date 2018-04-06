require 'busted.runner' ( )

local cuid = require 'cuid'

local fingerprint = "muh-hell3"

local function is_hex (text)
	return text: match ("[a-z0-9]+") == text
end

describe ("cuid unit testing -", function ( )
	randomize ( )

	it ("should comply the usecuid.org spec", function ( )
		local result = cuid.__structure ( )

		assert.same (result.prefix:      len ( ), 1)
		assert.same (result.timestamp:   len ( ), 8)
		assert.same (result.counter:     len ( ), 4)
		assert.same (result.fingerprint: len ( ), 4)
		assert.same (result.random:      len ( ), 8)

		assert.truthy (is_hex (result.prefix))
		assert.truthy (is_hex (result.timestamp))
		assert.truthy (is_hex (result.counter))
		assert.truthy (is_hex (result.fingerprint))
		assert.truthy (is_hex (result.random))
	end)

	it ("should generate a proper cuid", function ( )
		local id = cuid.generate ( )

		assert.same (id: len ( ), 25)
		assert.same (id: sub (1, 1), 'c')

		assert.truthy (is_hex (id))
	end)

	it ("should not collide cuids", function ( )
		local ITERATIONS = math.random (100000, 1000000)

		local cuids     = { }
		local collision = false

		for _ = 1, ITERATIONS do
			local id = cuid.generate ( )

			if cuids[ id ] then
				collision = true
				break
			end

			cuids[ id ] = true
		end

		assert.falsy (collision)
	end)

	it ("fingerprint should not resemble the fingerprint feed", function ( )
		cuid.__set_fingerprint (fingerprint)
		finally (cuid.__reset_fingerprint)

		local result = cuid.__structure ( )
		assert.are_not.same (result.fingerprint, "ell3")
	end)

	it ("fingerprint should generate valid hexadecimal values", function ( )
		cuid.__set_fingerprint (fingerprint)
		finally (cuid.__reset_fingerprint)

		local result = cuid.__structure ( )
		assert.truthy (is_hex (result.fingerprint))
	end)
end)
