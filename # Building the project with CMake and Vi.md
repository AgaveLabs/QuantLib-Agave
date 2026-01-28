# install Boost
.\vcpkg install boost-test:x64-windows-static
.\vcpkg install boost:x64-windows-static
.\vcpkg install boost-math:x64-windows-static

# Building the project with CMake and Visual Studio 2026

rmdir /s /q build
cmake -S . -B build -G "Visual Studio 18 2026" -A x64 ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DCMAKE_TOOLCHAIN_FILE="C:\Users\BenoitPinguet\dev\vcpkg\scripts\buildsystems\vcpkg.cmake"
cmake --build build --config Release --target install

# to build just library
cmake --build build --config Release --target ql_library

# then build tests
cmake --build build --config Release --target ql_test_suite

# list all targets
cmake --build build --config Release --target help

# Run tests
ctest --test-dir build -C Release

# Add to test-suite/CMakeLists.tst
find_package(Boost CONFIG REQUIRED COMPONENTS unit_test_framework)

target_link_libraries(ql_test_suite PRIVATE Boost::unit_test_framework)

target_compile_definitions(ql_test_suite PRIVATE BOOST_TEST_DYN_LINK)

