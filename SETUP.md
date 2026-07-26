# CLEO project configuration

## Prerequisites
- [Premake5](https://premake.github.io/) (included in the repository as `premake5.exe`)
- [Visual Studio 2026](https://visualstudio.microsoft.com/)
- Git (with submodule support)

## Setup

1. Clone the repository with submodules:
   ```
   git clone --recursive https://github.com/user/CLEO5.git
   ```
   If already cloned without submodules:
   ```
   git submodule update --init --recursive
   ```

2. Generate Visual Studio project files:
   ```
   premake5 vs2026
   ```

3. Open the generated `CLEO5.sln` in Visual Studio 2026.

4. Build the solution (Debug or Release configuration).

## Output

- **CLEO5 Core**: `.output/<Configuration>/CLEO.asi`
- **Plugins**: `cleo_plugins/.output/SA.<PluginName>.cleo`

## Optional: Game integration

Set the `GTA_SA_DIR` environment variable to your GTA San Andreas installation directory. Post-build events will automatically copy built files to the game directory.

If GTA SA is installed in a non-default location, set the environment variable manually:
```
setx GTA_SA_DIR "C:\path\to\GTA San Andreas"
```
