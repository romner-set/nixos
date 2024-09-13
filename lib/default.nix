# https://github.com/EmergentMind/nix-config/blob/dev/lib/default.nix
{lib, ...}:
with lib; rec {
  # PATHS
  relativeToRoot = lib.path.append ../.;
  scanPath = path:
    builtins.map (f: (path + "/${f}")) (builtins.attrNames
      (lib.attrsets.filterAttrs (path: _type:
        (_type == "directory") # include directories
        || (
          # FIXME this barfs when child directories don't contain a default.nix
          # example:
          # error: getting status of '/nix/store/mx31x8530b758ap48vbg20qzcakrbc8 (see hosts/common/core/services/default.nix)a-source/hosts/common/core/services/default.nix': No such file or directory
          # I created a blank default.nix in hosts/common/core/services to work around
          (path != "default.nix") # ignore default.nix
          && (lib.strings.hasSuffix ".nix" path) # include .nix files
        )) (builtins.readDir path)));
  scanPaths = paths: lib.lists.concatMap (dir: map (n: "${dir}/${n}") (builtins.attrNames (builtins.readDir dir))) paths;

  # MATH
  mod = n: d: n - (n / d) * d;

  ## Conversions
  decToHex = let
    table = ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f"];
  in
    q: a:
      if q > 0
      then (decToHex (q / 16) ((elemAt table (mod q 16)) + a))
      else a;

  binToDec' = n: out: base:
    if n == 0
    then out
    else binToDec' (n / 10) (out + (mod n 10) * base) (base * 2);
  binToDec = n: binToDec' n 0 1;

  ## Subnet math
  ### I hate subnet masks, literally the only thing that needs this is the ip= linux kernel param
  ### IPv4-only because who in their right fucking mind would use subnet masks with IPv6
  subnet = rec {
    lengthToBits' = i: len: current:
      if i == 8
      then current
      else let
        char =
          if i < len
          then "1"
          else "0";
      in
        lengthToBits' (i + 1) len (current + char);
    lengthToBits = len: [
      (lengthToBits' 0 len "")
      (lengthToBits' 0 (len - 8) "")
      (lengthToBits' 0 (len - 16) "")
      (lengthToBits' 0 (len - 24) "")
    ];

    lengthToMaskList = len:
      with lib.strings;
        map (n:
          toString (
            if n == "00000000" # toInt doesn't like leading zeroes
            then 0
            else binToDec (toInt n)
          )) (lengthToBits len);

    lengthToMask = len:
      with lib.strings;
        concatStrings (intersperse "." (lengthToMaskList len));

    getNetworkAddr = addr: subnetLen:
      with lib.strings;
        concatStrings (intersperse "." (map (v: toString (builtins.bitAnd (toInt v.fst) (toInt v.snd))) (
          lib.lists.zipLists (lengthToMaskList subnetLen) (splitString "." addr)
        )));
  };
}
