require 'busted.runner' ( )

local cuid = require 'cuid'

local fingerprint = "muh-hell3"

local function is_base36 (text)
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

		assert.truthy (is_base36 (result.prefix))
		assert.truthy (is_base36 (result.timestamp))
		assert.truthy (is_base36 (result.counter))
		assert.truthy (is_base36 (result.fingerprint))
		assert.truthy (is_base36 (result.random))
	end)

	it ("should generate a proper cuid", function ( )
		local id = cuid.generate ( )

		assert.same (id: len ( ), 25)
		assert.same (id: sub (1, 1), 'c')

		assert.truthy (is_base36 (id))
	end)

	it ("should generate a proper cuid slug", function ( )
		local slug = cuid.slug ( )

		assert.same (slug: len ( ), 8)
		assert.truthy (is_base36 (slug))
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
		local previous = cuid.__structure ( )

		local result = cuid.__structure (fingerprint)
		assert.are_not.same (result.fingerprint, "ell3")

		local current = cuid.__structure ( )
		assert.same (previous.fingerprint, current.fingerprint)
	end)

	it ("fingerprint should generate valid hexadecimal values", function ( )
		do
			local result   = cuid.__structure (fingerprint)
			assert.truthy (is_base36 (result.fingerprint))
		end

		do
			local result = cuid.generate (fingerprint)
			assert.truthy (is_base36 (result))
		end

		do
			local result = cuid.slug (fingerprint)
			assert.truthy (is_base36 (result))
		end
	end)
end)
