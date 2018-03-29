require 'busted.runner' ( )

local cuid = require 'cuid'

describe ("cuid unit testing", function ( )
	it ("should comply the usecuid.org spec", function ( )
		local result = cuid.__structure ( )

		assert.same (result.prefix:      len ( ), 1)
		assert.same (result.timestamp:   len ( ), 8)
		assert.same (result.counter:     len ( ), 4)
		assert.same (result.fingerprint: len ( ), 4)
		assert.same (result.random:      len ( ), 8)
	end)

	it ("should generate a proper cuid", function ( )
		local id = cuid.generate ( )

		assert.same (id: len ( ), 25)
		assert.same (id: sub (1, 1), 'c')
	end)

	it ("should be able to define a custom fingerprint", function ( )
		local fingerprint = "hell3"

		cuid.__set_fingerprint (fingerprint)

		local result = cuid.__structure ( )

		assert.same (result.fingerprint, "ell3")
	end)

	it ("should not collide cuids", function ( )
		local ITERATIONS = math.random (200000, 1200000)

		local cuids = { }

		for _ = 1, ITERATIONS do
			local id = cuid.generate ( )

			assert.falsy (cuids[ id ])

			cuids[ id ] = true
		end
	end)
end)
