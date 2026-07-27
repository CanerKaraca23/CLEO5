workspace "Test" configurations { "Debug" } project "Test" kind "ConsoleApp" buildoptions { '/DTARGET_NAME=R\\"(' .. "MyTarget" .. ')\\"' } files { "main.cpp" }
