cfg: {
  id = 18;

  shares = [
    {
      proto = "virtiofs";
      tag = "samba-data";
      source = "/vm/samba";
      mountPoint = "/var/lib/samba";
    }
    {
      proto = "virtiofs";
      tag = "samba-share-data";
      source = "/data";
      mountPoint = "/shared/data";
    }
  ];
}
