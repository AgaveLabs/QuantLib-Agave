 $swigPath = "C:\Program Files\swigwin-4.4.1"
if ($Env:PATH.Split(';') -notcontains $swigPath) {
    $Env:PATH += ";$swigPath"
}
$vcpkgInc = "C:\Users\BenoitPinguet\dev\vcpkg\installed\x64-windows\include"
if (Test-Path "$vcpkgInc\boost\config.hpp") {
    $Env:VCPKG_INC = $vcpkgInc
}
