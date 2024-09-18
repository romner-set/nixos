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
    {
      proto = "virtiofs";
      tag = "samba-share-misc";
      source = "/misc";
      mountPoint = "/shared/misc";
    }
    {
      proto = "virtiofs";
      tag = "samba-share-srv";
      source = "/vm/nginx/srv";
      mountPoint = "/shared/srv";
    }
  ];
}
