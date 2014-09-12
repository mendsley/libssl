--
-- Create an openssl namespace to isolate the plugin
--
	premake.extensions.openssl = {}

	local openssl = premake.extensions.openssl

	openssl.printf = function(msg, ...)
		printf("[openssl] " .. msg, ...)
	end

	openssl.printf("Premake OpenSSL Extension")

	include "impl.lua"
	include "proj.lua"
