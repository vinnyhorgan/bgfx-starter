--
-- premake-export-compile-commands.lua
--
-- Export a compile_commands.json file from a Premake 5 project.
--

local p = premake

p.modules.export_compile_commands = {}
local m = p.modules.export_compile_commands

local function get_include_dirs(cfg)
    local dirs = {}
    for _, dir in ipairs(cfg.includedirs) do
        table.insert(dirs, "-I" .. p.project.getrelative(cfg.project, dir))
    end
    return dirs
end

local function get_defines(cfg)
    local defines = {}
    for _, define in ipairs(cfg.defines) do
        table.insert(defines, "-D" .. define)
    end
    return defines
end

function m.onWorkspace(wks)
    local commands = {}
    
    for wks_cfg in p.workspace.eachconfig(wks) do
        if wks_cfg.name:lower() == "debug" then -- We only need one config for LSP
            for prj in p.workspace.eachproject(wks) do
                local cfg = p.project.getconfig(prj, wks_cfg.buildcfg, wks_cfg.platform)
                
                local includes = get_include_dirs(cfg)
                local defines = get_defines(cfg)
                
                -- Common flags
                local common_flags = {
                    "-std=c++17",
                    "-g",
                    "-m64"
                }
                
                if os.target() == "macosx" then
                    table.insert(common_flags, "-x")
                    table.insert(common_flags, "objective-c++")
                end

                for _, file in ipairs(prj.files) do
                    if path.iscppfile(file) then
                        local abs_file = path.getabsolute(file)
                        local rel_file = p.project.getrelative(prj, file)
                        
                        local command = {
                            "clang++"
                        }
                        
                        for _, flag in ipairs(common_flags) do table.insert(command, flag) end
                        for _, d in ipairs(defines) do table.insert(command, d) end
                        for _, i in ipairs(includes) do table.insert(command, i) end
                        
                        table.insert(command, "-c")
                        table.insert(command, rel_file)
                        
                        table.insert(commands, {
                            directory = wks.location,
                            command = table.concat(command, " "),
                            file = rel_file
                        })
                    end
                end
            end
        end
    end
    
    local outfile = path.join(wks.location, "../compile_commands.json")
    local f = io.open(outfile, "w")
    f:write("[\n")
    for i, cmd in ipairs(commands) do
        f:write("  {\n")
        f:write('    "directory": "' .. cmd.directory .. '",\n')
        f:write('    "command": "' .. cmd.command:gsub("\\", "\\\\"):gsub('"', '\\"') .. '",\n')
        f:write('    "file": "' .. cmd.file .. '"\n')
        f:write("  }")
        if i < #commands then f:write(",") end
        f:write("\n")
    end
    f:write("]\n")
    f:close()
    print("Generated compile_commands.json")
end

newaction {
    trigger = "export-compile-commands",
    description = "Export compile_commands.json",
    onWorkspace = m.onWorkspace
}