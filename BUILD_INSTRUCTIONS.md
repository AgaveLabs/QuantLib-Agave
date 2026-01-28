# QuantLib Build Fix Summary

## Problem
The test suite failed to link with error `LNK1107: invalid or corrupt file: cannot read at 0x2F0` because CMake was picking up the Boost DLL path instead of the import library (.lib) path when linking.

## Root Cause
- vcpkg builds Boost as DLLs on Windows
- CMake's FindBoost module (deprecated in modern CMake) was not properly handling vcpkg's Boost installation
- The library needed to link against the import library (`.lib`) but was finding the DLL directly

## Solution Applied
1. **Updated root CMakeLists.txt** to use modern Boost CONFIG mode instead of deprecated FindBoost:
   - Changed `find_package(Boost ${QL_BOOST_VERSION} REQUIRED)` to `find_package(Boost ${QL_BOOST_VERSION} CONFIG REQUIRED)`
   - Added preference for .lib files: `set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})`

2. **Updated test-suite/CMakeLists.txt** to properly define Boost DLL usage:
   - Always define `BOOST_ALL_DYN_LINK` and `BOOST_TEST_DYN_LINK` for both `ql_test` and `ql_test_suite` targets
   - This ensures consistent symbol linkage for Boost.Test framework

3. **Removed duplicate find_package**: Removed early `find_package(Boost REQUIRED COMPONENTS unit_test_framework)` from root CMakeLists.txt line 4

## Build Commands

### Full Build (from scratch)
```powershell
cd C:\Users\BenoitPinguet\dev\QuantLib-Agave

# Configure with vcpkg toolchain
cmake -B build -S . `
  -DCMAKE_TOOLCHAIN_FILE=C:/Users/BenoitPinguet/dev/vcpkg/scripts/buildsystems/vcpkg.cmake `
  -DCMAKE_PREFIX_PATH=C:/Users/BenoitPinguet/dev/vcpkg/installed/x64-windows `
  -DCMAKE_BUILD_TYPE=Release

# Build library
cmake --build build --config Release --target ql_library

# Build test suite
cmake --build build --config Release --target ql_test_suite

# Install
cmake --build build --config Release --target install
```

### Quick Rebuild (after changes to test files only)
```powershell
cd C:\Users\BenoitPinguet\dev\QuantLib-Agave
cmake --build build --config Release --target ql_test_suite
```

## Files Modified
1. `CMakeLists.txt` - Lines 1-4, 144-155, 167-170
2. `test-suite/CMakeLists.txt` - Lines 1-4, 221-236

## Notes
- The library itself (ql_library) compiles fine as it doesn't depend on Boost.Test
- Only the test suite had linking issues
- vcpkg Boost version: 1.90.0
- The fix ensures proper dynamic linking with Boost DLLs
