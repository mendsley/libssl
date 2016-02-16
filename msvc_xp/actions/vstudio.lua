--
-- vstudio.lua
-- PS4 integration for vstudio.
-- Copyright (c) 2014 Matthew Endsley
--
--

	local vstudio = premake.vstudio
	local vc2010 = vstudio.vc2010

	premake.override(vc2010, "platformToolset", function(base, cfg)
		if _ACTION > "vs2010" and cfg.flags.TargetWindowsXP ~= nil then
			local toolset = "V110_xp"
			if _ACTION == "vs2013" then toolset = "V120_xp" end
			vc2010.element(2, "PlatformToolset", nil, toolset)
		else
			return base(cfg)
		end
	end)
