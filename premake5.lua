workspace "CLEO5"
    configurations { "Debug", "Release" }
    platforms { "Win32" }
    architecture "x86"
    location "."

    language "C++"
    cppdialect "C++latest"
    systemversion "10.0"
    staticruntime "On"

    warnings "Extra"
    disablewarnings { "4100", "4458", "4505", "4245", "4244", "4201", "4189", "4389", "4456", "4459" }
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
        functionlevellinking "On"
        buildoptions { "/Oi" }
        linktimeoptimization "On"

    filter {}

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

    filter "files:third-party/**.cpp"
        enablepch "Off"
    filter "files:source/crc32.cpp"
        enablepch "Off"
    filter "files:source/OpcodeInfoDatabase.cpp"
        enablepch "Off"

    filter {}

    linkoptions { "/SAFESEH:NO", "/MANIFEST:NO" }
    buildoptions { "/sdl" }
    
    filter "configurations:Release"
        rtti "Off"
        linkoptions { "/ignore:4075" }

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

local function setup_cleo_plugin(name, dir, target)
    project(name)
        kind "SharedLib"
        characterset "MBCS"
        targetname(target)
        targetextension ".cleo"
        targetdir "cleo_plugins/.output"
        objdir("cleo_plugins/" .. dir .. "/.obj/%{cfg.buildcfg}")

        buildoptions { '/DTARGET_NAME=R\\"(' .. target .. ')\\"' }
        resdefines { "TARGET_NAME=" .. target .. ".cleo" }

        includedirs { "cleo_sdk" }
        libdirs { "cleo_sdk" }
        links { "CLEO5" }

        files { 
            "cleo_plugins/Resource.rc",
            "cleo_plugins/" .. dir .. "/**.cpp",
            "cleo_plugins/" .. dir .. "/**.h"
        }

        resincludedirs { "cleo_sdk", "source" }

        postbuildcommands {
            'if defined GTA_SA_DIR ( taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING" >nul 2>&1 & xcopy /Y "$(OutDir)$(TargetName).*" "$(GTA_SA_DIR)\\cleo\\cleo_plugins\\" )'
        }

        debugcommand "$(GTA_SA_DIR)\\gta_sa.exe"
        debugdir "$(GTA_SA_DIR)"
end

setup_cleo_plugin("Audio", "Audio", "SA.Audio")
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

setup_cleo_plugin("DebugUtils", "DebugUtils", "SA.DebugUtils")
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

setup_cleo_plugin("FileSystemOperations", "FileSystemOperations", "SA.FileSystemOperations")

setup_cleo_plugin("GameEntities", "GameEntities", "SA.GameEntities")
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

setup_cleo_plugin("IniFiles", "IniFiles", "SA.IniFiles")

setup_cleo_plugin("Input", "Input", "SA.Input")
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

setup_cleo_plugin("Math", "Math", "SA.Math")

setup_cleo_plugin("MemoryOperations", "MemoryOperations", "SA.MemoryOperations")
    files {
        "third-party/plugin-sdk/plugin_sa/game_sa/CPools.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/PluginBase.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }

setup_cleo_plugin("Text", "Text", "SA.Text")
    links { "Shlwapi" }
    files {
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
