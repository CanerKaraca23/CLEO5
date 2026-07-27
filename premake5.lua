-- ============================================================================
-- CLEO5 Build System - Premake5 Configuration
-- Generates Visual Studio solution and project files
-- Usage: premake5 vs2026
-- ============================================================================

workspace "CLEO5"
    configurations { "Debug", "Release" }
    platforms { "Win32" }
    architecture "x86"
    location "."

    language "C++"
    cppdialect "C++latest"
    systemversion "10.0"
    staticruntime "On"

    -- Common compiler settings
    warnings "Extra"                        -- /W4
    buildoptions { "/Zc:threadSafeInit-" }  -- Disable thread-safe static init
    multiprocessorcompile "On"               -- /MP

    -- Common preprocessor definitions
    defines { "NOMINMAX", "RW", "GTASA" }

    -- Common include directories (plugin-sdk)
    includedirs {
        "third-party/plugin-sdk/plugin_sa",
        "third-party/plugin-sdk/plugin_sa/game_sa",
        "third-party/plugin-sdk/plugin_sa/game_sa/rw",
        "third-party/plugin-sdk/plugin_sa/game_sa/enums",
        "third-party/plugin-sdk/shared",
        "third-party/plugin-sdk/shared/game",
    }

    -- Debug configuration
    filter "configurations:Debug"
        optimize "Off"
        defines { "_DEBUG" }
        symbols "On"
        runtime "Debug"

    -- Release configuration
    filter "configurations:Release"
        optimize "Speed"                    -- /O2
        defines { "_NDEBUG" }
        symbols "Off"
        runtime "Release"
        functionlevellinking "On"           -- /Gy
        buildoptions { "/Oi" }              -- Intrinsic functions
        linktimeoptimization "On"           -- /LTCG

    filter {}


-- ============================================================================
-- CLEO5 Core Library (CLEO.asi)
-- ============================================================================
project "CLEO5"
    kind "SharedLib"
    characterset "Unicode"
    targetname "CLEO"
    targetextension ".asi"
    targetdir ".output/%{cfg.buildcfg}"
    objdir ".output/.obj/%{cfg.buildcfg}"

    -- TARGET_NAME is only used by RC via TO_STR() stringification macro.
    -- C++ code does not reference it. Using buildoptions for C++ compiler
    -- so it doesn't conflict with the RC preprocessor.
    buildoptions { '/DTARGET_NAME=R\\"(CLEO)\\"' }

    includedirs {
        "third-party/simdjson/singleheader",
        "third-party/simpleini",
    }

    -- Precompiled header
    pchheader "stdafx.h"
    pchsource "source/stdafx.cpp"

    files {
        -- Source files
        "source/CCodeInjector.cpp",
        "source/CConfigManager.cpp",
        "source/CCustomOpcodeSystem.cpp",
        "source/CCustomScript.cpp",
        "source/CDebug.cpp",
        "source/CDmaFix.cpp",
        "source/CGameMenu.cpp",
        "source/CGameVersionManager.cpp",
        "source/CleoBase.cpp",
        "source/CModuleSystem.cpp",
        "source/CPluginSystem.cpp",
        "source/CScriptEngine.cpp",
        "source/crc32.cpp",
        "source/dllmain.cpp",
        "source/exports.cpp",
        "source/OpcodeInfoDatabase.cpp",
        "source/ScmFunction.cpp",
        "source/stdafx.cpp",

        -- Header files
        "source/CCodeInjector.h",
        "source/CConfigManager.h",
        "source/CCustomOpcodeSystem.h",
        "source/CCustomScript.h",
        "source/CDebug.h",
        "source/CDmaFix.h",
        "source/CGameMenu.h",
        "source/CGameVersionManager.h",
        "source/CleoBase.h",
        "source/CModuleSystem.h",
        "source/CPluginSystem.h",
        "source/CScriptEngine.h",
        "source/crc32.h",
        "source/FileEnumerator.h",
        "source/Mem.h",
        "source/OpcodeInfoDatabase.h",
        "source/resource.h",
        "source/ScmFunction.h",
        "source/ScriptDelegate.h",
        "source/ScriptUtils.h",
        "source/Singleton.h",
        "source/stdafx.h",

        -- SDK headers
        "cleo_sdk/CLEO.h",
        "cleo_sdk/CLEO_Utils.h",

        -- Module definition file (auto-detected by premake)
        "source/cleo.def",

        -- Resource file
        "source/CLEO5.rc",

        -- Plugin-SDK sources
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

        -- simdjson
        "third-party/simdjson/singleheader/simdjson.cpp",
        "third-party/simdjson/singleheader/simdjson.h",

        -- simpleini
        "third-party/simpleini/SimpleIni.h",
    }

    -- Per-file: Disable PCH and warning 4073 for plugin-sdk sources
    filter "files:third-party/plugin-sdk/**.cpp"
        enablepch "Off"
        disablewarnings { "4073", "4100", "4458", "4505", "4245", "4244", "4201", "4189", "4389", "4456", "4459", "4740" }

    -- Per-file: Disable PCH for simdjson
    filter "files:third-party/simdjson/**.cpp"
        enablepch "Off"
        disablewarnings { "4100", "4458", "4505", "4245", "4244", "4201", "4189", "4389", "4456", "4459", "4740" }

    -- Per-file: Disable PCH for standalone source files
    filter "files:source/crc32.cpp"
        enablepch "Off"

    filter "files:source/OpcodeInfoDatabase.cpp"
        enablepch "Off"

    filter {}

    -- Release-specific settings
    filter "configurations:Release"
        rtti "Off"
        linkoptions { "/SAFESEH:NO", "/MANIFEST:NO", "/ignore:4075" }
        buildoptions { "/sdl" }

        postbuildcommands {
            'xcopy /Y "$(OutDir)$(TargetName).lib" "$(SolutionDir)cleo_sdk\\"',
            'if defined GTA_SA_DIR (',
            'taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING"',
            'xcopy /Y "$(OutDir)$(TargetName).asi" "$(GTA_SA_DIR)\\"',
            ')',
        }

    -- Debug-specific settings
    filter "configurations:Debug"
        linkoptions { "/SAFESEH:NO" }
        buildoptions { "/sdl" }

        postbuildcommands {
            'xcopy /Y "$(OutDir)$(TargetName).lib" "$(SolutionDir)cleo_sdk\\"',
            'if defined GTA_SA_DIR (',
            'taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING"',
            'xcopy /Y "$(OutDir)$(TargetName).asi" "$(GTA_SA_DIR)\\"',
            'xcopy /Y "$(OutDir)$(TargetName).pdb" "$(GTA_SA_DIR)\\"',
            ')',
        }

    filter {}

    -- Debugger settings
    debugcommand "$(GTA_SA_DIR)\\gta_sa.exe"
    debugdir "$(GTA_SA_DIR)"


-- ============================================================================
-- CLEO Plugin Projects
-- ============================================================================

-- Helper: Common settings shared by all CLEO plugins
local function setup_cleo_plugin(name, dir, target)
    project(name)
        kind "SharedLib"
        characterset "MBCS"
        targetname(target)
        targetextension ".cleo"
        targetdir "cleo_plugins/.output"
        objdir("cleo_plugins/" .. dir .. "/.obj/%{cfg.buildcfg}")

        -- C++ compiler: TARGET_NAME as raw string literal
        buildoptions { '/DTARGET_NAME=R\\"(' .. target .. ')\\"' }

        -- RC resource compiler: TARGET_NAME as plain filename for TO_STR()
        resdefines { "TARGET_NAME=" .. target .. ".cleo" }

        includedirs { "cleo_sdk" }
        libdirs { "cleo_sdk" }
        links { "CLEO5" }

        files { "cleo_plugins/Resource.rc" }

        -- Resource includes for relative paths in Resource.rc
        resincludedirs {
            "cleo_sdk",
            "source",
        }

        -- Per-file: Disable PCH and warning 4073 for plugin-sdk sources
        filter "files:third-party/plugin-sdk/**.cpp"
            enablepch "Off"
            disablewarnings { "4073", "4100", "4458", "4505", "4245", "4244", "4201", "4189", "4389", "4456", "4459", "4740" }
        filter {}

        -- Post-build: copy to game directory if available
        postbuildcommands {
            'if defined GTA_SA_DIR (',
            'taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING"',
            'xcopy /Y "$(OutDir)$(TargetName).*" "$(GTA_SA_DIR)\\cleo\\cleo_plugins\\"',
            ')',
        }

        -- Debugger
        debugcommand "$(GTA_SA_DIR)\\gta_sa.exe"
        debugdir "$(GTA_SA_DIR)"
end

-- ----------------------------------------------------------------------------
-- Audio Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("Audio", "Audio", "SA.Audio")

    includedirs { "cleo_plugins/Audio/bass" }
    libdirs { "cleo_plugins/Audio/bass" }
    links { "bass" }

    files {
        "cleo_plugins/Audio/Audio.cpp",
        "cleo_plugins/Audio/C3DAudioStream.cpp",
        "cleo_plugins/Audio/C3DAudioStream.h",
        "cleo_plugins/Audio/CAudioStream.cpp",
        "cleo_plugins/Audio/CAudioStream.h",
        "cleo_plugins/Audio/CInterpolatedValue.h",
        "cleo_plugins/Audio/CSoundSystem.cpp",
        "cleo_plugins/Audio/CSoundSystem.h",
        "cleo_plugins/Audio/bass/bass.h",

        -- Plugin-SDK sources
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

    -- Audio has unconditional post-build (no if check)
    postbuildcommands {
        'taskkill /IM gta_sa.exe /F /FI "STATUS eq RUNNING"',
        'xcopy /Y "$(OutDir)$(TargetName).*" "$(GTA_SA_DIR)\\cleo\\cleo_plugins\\"',
    }


-- ----------------------------------------------------------------------------
-- DebugUtils Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("DebugUtils", "DebugUtils", "SA.DebugUtils")

    includedirs {
        "source",
        "third-party/simdjson/singleheader",
    }

    files {
        "cleo_plugins/DebugUtils/DebugUtils.cpp",
        "cleo_plugins/DebugUtils/ScreenLog.cpp",
        "cleo_plugins/DebugUtils/ScreenLog.h",
        "cleo_plugins/DebugUtils/ScriptLog.cpp",
        "cleo_plugins/DebugUtils/ScriptLog.h",

        -- Shared source files from root
        "source/crc32.cpp",
        "source/OpcodeInfoDatabase.cpp",
        "third-party/simdjson/singleheader/simdjson.cpp",

        -- Plugin-SDK sources
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

    -- simdjson also needs NoPCH
    filter "files:third-party/simdjson/**.cpp"
        enablepch "Off"
    filter {}


-- ----------------------------------------------------------------------------
-- FileSystemOperations Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("FileSystemOperations", "FileSystemOperations", "SA.FileSystemOperations")

    files {
        "cleo_plugins/FileSystemOperations/FileSystemOperations.cpp",
        "cleo_plugins/FileSystemOperations/FileUtils.cpp",
        "cleo_plugins/FileSystemOperations/FileUtils.h",
    }


-- ----------------------------------------------------------------------------
-- GameEntities Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("GameEntities", "GameEntities", "SA.GameEntities")

    files {
        "cleo_plugins/GameEntities/GameEntities.cpp",

        -- Plugin-SDK sources
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


-- ----------------------------------------------------------------------------
-- IniFiles Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("IniFiles", "IniFiles", "SA.IniFiles")

    files {
        "cleo_plugins/IniFiles/IniFiles.cpp",
    }


-- ----------------------------------------------------------------------------
-- Input Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("Input", "Input", "SA.Input")

    files {
        "cleo_plugins/Input/main.cpp",

        -- Plugin-SDK sources
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


-- ----------------------------------------------------------------------------
-- Math Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("Math", "Math", "SA.Math")

    files {
        "cleo_plugins/Math/Math.cpp",
    }


-- ----------------------------------------------------------------------------
-- MemoryOperations Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("MemoryOperations", "MemoryOperations", "SA.MemoryOperations")

    files {
        "cleo_plugins/MemoryOperations/MemoryOperations.cpp",

        -- Plugin-SDK sources
        "third-party/plugin-sdk/plugin_sa/game_sa/CPools.cpp",
        "third-party/plugin-sdk/plugin_sa/game_sa/CTheScripts.cpp",
        "third-party/plugin-sdk/shared/DynAddress.cpp",
        "third-party/plugin-sdk/shared/GameVersion.cpp",
        "third-party/plugin-sdk/shared/Patch.cpp",
        "third-party/plugin-sdk/shared/PluginBase.cpp",
        "third-party/plugin-sdk/shared/game/CRGBA.cpp",
    }


-- ----------------------------------------------------------------------------
-- Text Plugin
-- ----------------------------------------------------------------------------
setup_cleo_plugin("Text", "Text", "SA.Text")

    links { "Shlwapi" }

    files {
        "cleo_plugins/Text/crc32.cpp",
        "cleo_plugins/Text/crc32.h",
        "cleo_plugins/Text/CTextManager.cpp",
        "cleo_plugins/Text/CTextManager.h",
        "cleo_plugins/Text/ScriptDrawing.cpp",
        "cleo_plugins/Text/ScriptDrawing.h",
        "cleo_plugins/Text/ScriptDrawsState.h",
        "cleo_plugins/Text/Text.cpp",

        -- Plugin-SDK sources
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
