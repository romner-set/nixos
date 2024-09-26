{lib, ...}:
with lib; rec {
  # PATHS
  ## https://github.com/EmergentMind/nix-config/blob/e68e8554dc82226e8158728222ca33a81d22d4b7/lib/default.nix
  relativeToRoot = lib.path.append ../.;
  scanPath = path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
            (_type == "directory") # include directories
            || (
              (path != "default.nix") # ignore default.nix
              && (lib.strings.hasSuffix ".nix" path) # include .nix files
            )
        ) (builtins.readDir path)
      )
    );
  scanPaths = paths: lib.lists.concatMap (dir: map (n: "${dir}/${n}") (builtins.attrNames (builtins.readDir dir))) paths;

  # MISC
  strings = rec {
    zeroPad = len: n: 
      if builtins.stringLength n < len
      then zeroPad (len - 1) "0${n}"
      else n;
  };

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
        map (n: toString (binToDec (toIntBase10 n))) (lengthToBits len);

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
