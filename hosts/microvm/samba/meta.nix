cfg: {
  id = 18;

  shares = [
    {
      proto = "virtiofs";
      tag = "samba-data";
      source = "/data";
      mountPoint = "/data";
    }
  ];
}
