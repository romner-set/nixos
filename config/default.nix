{configLib, ...}: {
  imports = configLib.scanPaths [
    ./core
    ./desktop
    ./server
    ./microvm
    #./vps
  ];
}
