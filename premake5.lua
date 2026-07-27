workspace "CLEO5"
    configurations { "Debug", "Release" }
    platforms { "Win32" }
    architecture "x86"

    language "C++"
    cppdialect "C++latest"
    staticruntime "On"

    warnings "Extra"
    disablewarnings { "4073", "4100", "4458", "4505", "4245", "4244", "4201", "4189", "4389", "4456", "4459", "4740" }
    buildoptions { "/Zc:threadSafeInit-" }
    multiprocessorcompile "On"

    defines { "NOMINMAX", "RW", "GTASA" }

    includedirs {
        "third-party/plugin-sdk/plugin_sa",
        "third-party/plugin-sdk/plugin_sa/game_sa",
        "third-party/plugin-sdk/plugin_sa/game_sa/rw",
        "third-party/plugin-sdk/plugin_sa/game_sa/enums",
        "third-party/plugin-sdk/shared",
        "third-party/plugin-sdk/shared/game",
    }

    filter "configurations:Debug"
        optimize "Off"
        defines { "_DEBUG" }
        symbols "On"
        runtime "Debug"

    filter "configurations:Release"
        optimize "Speed"
        defines { "_NDEBUG" }
        symbols "Off"
        runtime "Release"
        rtti "Off"
        flags { "NoBufferSecurityCheck" }
        buildoptions { "/Gw", "/Zc:__cplusplus", "/cgthreads8", "/permissive-", "/Zc:preprocessor", "/Ob3" }
        linktimeoptimization "On"

    filter {}

    linkoptions { "/SAFESEH:NO", "/MANIFEST:NO", "/ignore:4075" }

project "CLEO5"
    kind "SharedLib"
    characterset "Unicode"
    targetname "CLEO"
    targetextension ".asi"
    targetdir ".output/%{cfg.buildcfg}"
    objdir ".output/.obj/%{cfg.buildcfg}"

    buildoptions { '/DTARGET_NAME=R\\"(CLEO)\\"' }

    includedirs {
        "third-party/simdjson/singleheader",
        "third-party/simpleini",
    }

    pchheader "stdafx.h"
    pchsource "source/stdafx.cpp"

    files {
        "source/**.cpp",
        "source/**.h",
        "cleo_sdk/**.h",
        "source/cleo.def",
        "source/CLEO5.rc",

        "third-party/plugin-sdk/plugin_sa/game_sa/CFont.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CGame.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMenuManager.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CRunningScript.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CSprite2d.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTimer.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/RenderWare.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
        "third-party/plugin-sdk/shared/extensions/Screen.cpp",

        "third-party/simdjson/singleheader/simdjson.cpp",
        "third-party/simdjson/singleheader/simdjson.h",

        "third-party/simpleini/SimpleIni.h",
    }

    filter "files:third-party/**.cpp or files:source/crc32.cpp or files:source/OpcodeInfoDatabase.cpp"
        enablepch "Off"

    filter {}

    -- buildoptions { "/sdl" }
    
    filter {}

    postbuildcommands {
        'xcopy /Y "$(OutDir)$(TargetName).lib" "$(SolutionDir)cleo_sdk\\"',
        'if defined GTA_SA_DIR ( taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING" >nul 2>&1 & xcopy /Y "$(OutDir)$(TargetName).asi" "$(GTA_SA_DIR)\\" )'
    }

    filter "configurations:Debug"
        postbuildcommands {
            'if defined GTA_SA_DIR ( xcopy /Y "$(OutDir)$(TargetName).pdb" "$(GTA_SA_DIR)\\" )'
        }
        
    filter {}

    debugcommand "$(GTA_SA_DIR)\\gta_sa.exe"
    debugdir "$(GTA_SA_DIR)"

local function setup_cleo_plugin(name)
    local target = "SA." .. name
    project(name)
        kind "SharedLib"
        characterset "MBCS"
        targetname(target)
        targetextension ".cleo"
        targetdir "cleo_plugins/.output"
        objdir("cleo_plugins/" .. name .. "/.obj/%{cfg.buildcfg}")

        buildoptions { '/DTARGET_NAME=R\\"(' .. target .. ')\\"' }
        resdefines { 
            "TARGET_NAME=" .. target .. ".cleo",
            "PLUGIN_DESC=" .. name .. " Plugin"
        }

        includedirs { "cleo_sdk" }
        links { "CLEO5" }

        files { 
            "cleo_plugins/Resource.rc",
            "cleo_plugins/" .. name .. "/**.cpp",
            "cleo_plugins/" .. name .. "/**.h"
        }

        postbuildcommands {
            'if defined GTA_SA_DIR ( taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING" >nul 2>&1 & xcopy /Y "$(OutDir)$(TargetName).*" "$(GTA_SA_DIR)\\cleo\\cleo_plugins\\" )'
        }

        debugcommand "$(GTA_SA_DIR)\\gta_sa.exe"
        debugdir "$(GTA_SA_DIR)"
end

setup_cleo_plugin("Audio")
    includedirs { "cleo_plugins/Audio/bass" }
    libdirs { "cleo_plugins/Audio/bass" }
    links { "bass" }
    files {
        "third-party/plugin-sdk/plugin_sa/game_sa/CAEAudioHardware.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CCamera.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CPad.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CPlaceable.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CPools.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTimer.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/RenderWare.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/PluginBase.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }

setup_cleo_plugin("DebugUtils")
    includedirs { "source", "third-party/simdjson/singleheader" }
    files {
        "source/crc32.cpp",
        "source/OpcodeInfoDatabase.cpp",
        "third-party/simdjson/singleheader/simdjson.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CCheat.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CFont.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CGame.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CHud.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMenuManager.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMessages.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CRunningScript.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CSprite2d.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTimer.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/RenderWare.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }

setup_cleo_plugin("FileSystemOperations")

setup_cleo_plugin("GameEntities")
    files {
        "third-party/plugin-sdk/plugin_sa/game_sa/CAESound.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CAEWeaponAudioEntity.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CBaseModelInfo.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CCheat.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMenuManager.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CModelInfo.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CPed.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CPools.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CRadar.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CSprite2d.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CWorld.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/common.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }

setup_cleo_plugin("IniFiles")

setup_cleo_plugin("Input")
    files {
        "third-party/plugin-sdk/plugin_sa/game_sa/CCheat.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CControllerConfigManager.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMessages.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CText.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTimer.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/RenderWare.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
    }

setup_cleo_plugin("Math")

setup_cleo_plugin("MemoryOperations")
    files {
        "third-party/plugin-sdk/plugin_sa/game_sa/CPools.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/PluginBase.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }

setup_cleo_plugin("Text")
    links { "Shlwapi" }
    includedirs { "source" }
    files {
        "source/crc32.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CBaseModelInfo.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CGame.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CHud.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMenuManager.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMessages.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CMissionCleanup.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CModelInfo.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CRect.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CSprite2d.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CText.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTxdStore.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/RenderWare.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }
