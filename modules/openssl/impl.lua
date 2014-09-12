local openssl = premake.extensions.openssl
local opensslimpl = {}
openssl.impl = opensslimpl

--
-- Helper functions for navigating/processing the
-- OpenSSL source tree
--

-- sanity check the current configuration
opensslimpl.verify_cfg = function(cfg)
	assert(cfg.src_dir, "OpenSSL configuration does not contain a src_dir field")
	assert(cfg.include_dir, "OpenSSL configuration does not contain an include_dir field")
end

-- generate system-level defaults
opensslimpl.set_defaults = function()
	defines {
		"NO_WINDOWS_BRAINDEATH",
	}
	filter {"system:windows"}
		defines {
			"WIN32_LEAN_AND_MEAN",
			"_CRT_SECURE_NO_DEPRECATE",
			"OPENSSL_SYSNAME_WIN32",
		}
	filter {"architecture:x32 or architecture:x64"}
		defines {
			"L_ENDIAN",
		}

	filter {}
end

-- generate the OPENSSL_NO_* definitions for a configuration
opensslimpl.generate_defines = function(openssl_cfg)
	if not openssl_cfg then return end
	if not openssl_cfg.excluded_libs then return end

	local name
	for _, name in ipairs(openssl_cfg.excluded_libs) do
		defines {
			"OPENSSL_NO_" .. string.upper(name),
		}
	end
end

-- Parse an openssl makefile and generate a library description
opensslimpl.parse_library = function(pathToMakefile)
	local lib = {
		public_headers = {},
		private_headers = {},
		source = {},
	}

	-- read makefile, one line at a time
	local f = assert(io.open(pathToMakefile))
	local line = ""
	while true do
		local curr = f:read("*line")
		--line = line .. " " .. f:read("*line")
		if not curr then break end
		if #curr ~= 0 then
			line = line .. curr
			if curr:sub(#curr) == "\\" then
				line = line:sub(0, #line-1)
			else
				-- openssl splits header files into two categories:
				--    private headers (HEADER=...)
				--    public headers  (EXHEADER=...)
				-- source files are denoted by LIBSRC=...
				if string.sub(line, 1, 9) == "EXHEADER=" then
					lib.public_headers = opensslimpl.split_words(line:sub(10))
				elseif string.sub(line, 1, 7) == "HEADER=" then
					lib.private_headers = opensslimpl.split_words(line:sub(8))
				elseif string.sub(line, 1, 7) == "LIBSRC=" then
					lib.source = opensslimpl.split_words(line:sub(8))
				end

				line = ""
			end
		else
			line = ""
		end
	end

	-- handle the case where public headers are included in the private_headers
	local idx, header
	for idx, header in ipairs(lib.private_headers) do
		if header == "$(EXHEADER)" then
			lib.private_headers[idx] = nil
			for _, publicheader in ipairs(lib.public_headers) do
				table.insert(lib.private_headers, publicheader)
			end
			break
		end
	end

	return lib
end

-- split a line into a series of whitespace-delimited words
opensslimpl.split_words = function(line)
	local words = {}
	local word
	for word in line:gmatch("%S+") do
		table.insert(words, word)
	end
	return words
end

-- Find and generate a description for all OpenSSL libraries
opensslimpl.generate_libraries = function(OPENSSL_DIR)
	local libraries = {}

	-- find makefiles in crypto/
	local cryptoPrefix = OPENSSL_DIR .. "crypto/"
	local makefile
	for _, makefile in ipairs(os.matchfiles(cryptoPrefix .. "**/Makefile")) do
		local libraryName = path.getdirectory(makefile)
		if string.sub(libraryName, 1, #cryptoPrefix) == cryptoPrefix then
			libraryName = string.sub(libraryName, #cryptoPrefix + 1)
		end
		libraries["crypto/"..libraryName] = opensslimpl.parse_library(makefile)
	end

	-- describe the core crypto library
	libraries["crypto"] = opensslimpl.parse_library(OPENSSL_DIR .. "crypto/Makefile")

	-- describe the SSL library
	libraries["ssl"] = opensslimpl.parse_library(OPENSSL_DIR .. "ssl/Makefile")

	-- describe the core openssl library
	libraries[""] = opensslimpl.parse_library(OPENSSL_DIR .. "Makefile")

	return libraries
end

-- Determine if a library is excluded via the openssl_config properties
opensslimpl.library_excluded = function(cfg, libname, prefix)
	if not cfg then return false end
	if not cfg.excluded_libs then return false end

	local v
	for _, v in ipairs(cfg.excluded_libs) do
		if prefix .. v == libname then
			return true
		end
	end

	return false
end

