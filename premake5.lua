require "msvc_xp"
local openssl = require "openssl_ext"

-- Configure the OpenSSL build
local openssl_config = {
	src_dir = "src/",
	include_dir = "include/",
	excluded_libs = {
		"jpake",
		"rc5",
		"md2",
		"store",
		"engine",
		"sctp",
	},
}

if _ACTION == "headers" then
	print "Generating openssl header files"
	openssl.copy_public_headers(openssl_config)
	os.exit(0)
end

workspace "openssl"
	platforms {"x86", "x64"}
	configurations {"Release", "Release-static"}

	language "C"
	kind "StaticLib"

	location (".build/projects/" .. _ACTION .. "/")
	objdir (".build/obj/"  .. _ACTION .. "/")
	targetdir ("lib/" .. _ACTION .. "/%{cfg.architecture}/")

	flags {
		"NoEditAndContinue",
		"NoMinimalRebuild",
		"NoPCH",
		"Symbols",
		"Unicode",
		"FatalWarnings",
	}

	debugformat "c7"
	nativewchar "on"
	optimize "Speed"

	filter "Release-static"
		targetsuffix "-static"
		flags {
			"StaticRuntime",
		}

	filter {"action:vs*", "architecture:x64"}
		buildoptions {
			"/wd4244", -- warning C4244: 'EXPR': conversion from 'T' to 'U', possible loss of data
		}

	filter "action:vs*"
		buildoptions {
			"/wd4996", -- warning C4996: 'IDENT': was declared deprecated
			"/wd4267", -- warning C4267: 'EXPR': convertsion from 'T' to 'U', possible loss of data
			"/wd4311", -- warning C4311: 'EXPR': pointer truncation from 'T' to 'U'
		}
		linkoptions {
			"/IGNORE:4221", -- warning LNK4221: This object file does not define any previously public symbols...
		}
		defines {
			"_WINSOCK_DEPRECATED_NO_WARNINGS",
		}

	filter {}

project "crypto"
	openssl.crypto_project(openssl_config)

project "ssl"
	openssl.ssl_project(openssl_config)
	defines {
		"OPENSSL_NO_KRB5",
	}
