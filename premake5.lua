local ROOT_DIR = path.getdirectory(_SCRIPT) .. "/"

-- Load the OpenSSL extension
include "modules/openssl/openssl.lua"
local openssl = premake.extensions.openssl

-- Configure the OpenSSL build
openssl_config = {
	src_dir = ROOT_DIR .. "openssl_tarball/",
	include_dir = ROOT_DIR .. "include/",
	excluded_libs = {
		"jpake",
		"rc5",
		"md2",
		"store",
		"engine",
	},
}

--
-- Generate public OpenSSL header files
-- 
if _ACTION == "openssl_headers" then
	print "Generating header files"
	premake.extensions.openssl.copy_public_headers(openssl_config)
	os.exit(0)
end

--
-- Generate a solution with crypto/ssl Static Library projects
--
solution "libssl"
	configurations {
		"debug",
		"release",
	}

	language "C"
	kind "StaticLib"

	location (ROOT_DIR .. ".build/projects/")
	objdir (ROOT_DIR .. ".build/obj/")

	configuration {"debug"}
		targetdir (ROOT_DIR .. "lib/debug/")

	configuration {"release"}
		optimize "Speed"
		targetdir (ROOT_DIR .. "lib/release/")

	configuration {}

project "crypto"
	openssl.crypto_project(openssl_config)

project "ssl"
	openssl.ssl_project(openssl_config)
