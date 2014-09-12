local openssl = premake.extensions.openssl
local opensslimpl = openssl.impl

--
-- Copy the public openssl headers to the specified location
--   creates the directory $target_dir/openssl and populates
--   it
--
openssl.copy_public_headers = function(cfg)
	opensslimpl.verify_cfg(cfg)

	-- create the target directory
	local final_target = path.join(cfg.include_dir, "openssl") .. "/"
	os.mkdir(final_target)

	local libraries = opensslimpl.generate_libraries(cfg.src_dir)
	local name, desc
	for name, desc in pairs(libraries) do
		if not opensslimpl.library_excluded(cfg, name, "crypto/") then
			if desc.public_headers then
				local header
				for _, header in ipairs(desc.public_headers) do
					os.copyfile(cfg.src_dir .. name .. "/" .. header, final_target .. header)
				end
			end
		end
	end

end

--
-- Generate the commands needed for the crypto
-- project
--
openssl.crypto_project = function(cfg)
	opensslimpl.verify_cfg(cfg)
	includedirs {
		cfg.include_dir,
	}

	opensslimpl.set_defaults()
	opensslimpl.generate_defines(cfg)

	local libraries = opensslimpl.generate_libraries(cfg.src_dir)
	local libname, desc, filename
	for libname, desc in pairs(libraries) do
		if not opensslimpl.library_excluded(cfg, libname, "crypto/") then
			if string.sub(libname, 0, 6) == "crypto"  or libname == "" then
				for _, filename in ipairs(desc.source) do
					files {
						cfg.src_dir .. libname .. "/" .. filename
					}
				end
				for _, filename in ipairs(desc.private_headers) do
					includedirs {
						path.getdirectory(cfg.src_dir .. libname .. "/" .. filename)
					}
				end
			end
		end
	end
end

--
-- Generate the commands needed for the ssl project
--
openssl.ssl_project = function(cfg)
	opensslimpl.verify_cfg(cfg)
	includedirs {
		cfg.include_dir,
	}

	opensslimpl.set_defaults()
	opensslimpl.generate_defines(cfg)

	local libraries = openssl.impl.generate_libraries(cfg.src_dir)
	local libname, desc, filename
	for libname, desc in pairs(libraries) do
		if libname == "ssl" or libname == "crypto"  or libname == "" then
			if libname == "ssl" then
				for _, filename in ipairs(desc.source) do
					files {
						cfg.src_dir .. libname .. "/" .. filename
					}
				end
			end
			for _, filename in ipairs(desc.private_headers) do
				includedirs {
					path.getdirectory(cfg.src_dir .. libname .. "/" .. filename)
				}
			end
		end
	end
end


