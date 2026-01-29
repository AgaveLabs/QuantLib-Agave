@echo off

:: Configuration
set DEV_ROOT=C:\Users\BenoitPinguet\dev

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script requires administrator privileges.
    echo Please run this script as Administrator.
    exit /b 1
)

:: Remove build directory with retry mechanism
echo Cleaning build directory...
if exist build (
    rmdir /s /q build 2>nul
    if exist build (
        echo Build directory in use, waiting...
        timeout /t 2 /nobreak >nul
        rmdir /s /q build 2>nul
    )
    if exist build (
        echo Build directory still locked, using PowerShell to force delete...
        powershell -Command "Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue"
        timeout /t 1 /nobreak >nul
    )
    if exist build (
        echo WARNING: Could not delete build directory. Trying to rename...
        if exist build_old (
            rmdir /s /q build_old 2>nul
            powershell -Command "Remove-Item -Recurse -Force build_old -ErrorAction SilentlyContinue" 2>nul
        )
        rename build build_old 2>nul
        if exist build (
            echo ERROR: Build directory is locked and cannot be removed or renamed.
            echo Please close any programs that may be using files in the build directory.
            echo Press any key to continue anyway, or Ctrl+C to abort...
            pause >nul
        ) else (
            echo Renamed old build to build_old, will be cleaned up later.
        )
    )
)

set VCPKG_ROOT=%DEV_ROOT%\vcpkg
set VCPKG_TOOLCHAIN=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake

if not exist "%VCPKG_TOOLCHAIN%" (
    echo ERROR: vcpkg toolchain file not found at: %VCPKG_TOOLCHAIN%
    echo Please verify your vcpkg installation path.
    exit /b 1
)

cmake -S . -B build -G "Visual Studio 18 2026" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=%VCPKG_TOOLCHAIN% ^
  -DVCPKG_TARGET_TRIPLET=x64-windows ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreadedDLL ^
  -DCMAKE_INSTALL_PREFIX=%DEV_ROOT%\QuantLib-Agave\ql-install

cmake --build build --config Release --target install

:: Clean up old build directory if it exists
if exist build_old (
    echo.
    echo Cleaning up old build directory...
    rmdir /s /q build_old 2>nul
    powershell -Command "Remove-Item -Recurse -Force build_old -ErrorAction SilentlyContinue" 2>nul
)
