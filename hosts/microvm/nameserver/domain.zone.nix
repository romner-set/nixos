{
  lib,
  domain,
  addrs,
  host,
  vms,
  net,
}:
with lib.attrsets;
with lib.strings; let
  TLSA = "BF1C238F30DC82DA79F01B85CB0B30C3FBB4A091E01ECC7EFD6AF958B1C04AC7";
  spfAddrs = "ip4:${host.ipv4} ip6:${net.ipv6.subnet.microvmPublic}::${toString vms.mail.id}";
in
  concatStrings [
    ''
      $TTL 3600
      $ORIGIN ${domain}.

      ; zone metadata
      @                     IN  SOA           ns1 admin (
                                                        2024050900 ; serial number
                                                        900        ; refresh
                                                        300        ; update retry
                                                        604800     ; expiry
                                                        900        ; minimum
                                                        )

                            IN  NS            ns1
                            IN  NS            ns2

      ; nameservers
    ''
    (concatImapStrings (i: addr: ''
        ns${toString i}               IN  AAAA          ${addr.ipv6}
        ns${toString i}               IN  A             ${addr.ipv4}
        _dns.ns${toString i}          IN  SVCB          2 ns${toString i} alpn=dot
        ;_dns.ns${toString i}          IN  SVCB          1 ns${toString i} alpn=h2,h3 dohpath=/dns-query{?dns}
      '')
      addrs)
    ''

      ; SSH
      ;@                     IN  SSHFP         1 1 BA6B9A49143417A3AEF2F1757C1DAC0029271105
      ;@                     IN  SSHFP         1 2 C5B2FFBD7B5FFB44A97E541B72E2324EBAD474E828C0441445427B02A71663CD
      ;@                     IN  SSHFP         4 1 10F4803601771CE8E21A220B4A83553C1170DAF2
      ;@                     IN  SSHFP         4 2 DCDB72D050EC403BF7136BBCCF0AB5F55EACB01755D9ABE1E7689405E35F799E

      ; CAA
      @                     IN  CAA           0 iodef "mailto:admin@${domain}"
      @                     IN  CAA           0 contactemail "admin@${domain}"
      @                     IN  CAA           0 issue "sectigo.com"

      ; A/AAAA/CNAME
    ''
    /*
    (concatMapStrings (addr: ''
      @                 IN  A             ${addr.ipv4}
      @                 IN  AAAA          ${addr.ipv6}
      *                 IN  A             ${addr.ipv4}
      *                 IN  AAAA          ${addr.ipv6}
    '')
    addrs)
    */
    ''
      @                 IN  A             ${host.ipv4}
      @                 IN  AAAA          ${host.ipv6}
      ;*                 IN  A             ${host.ipv4}
      ;*                 IN  AAAA          ${host.ipv6}
      ;mail              IN  A             ${host.ipv4}
      ;mail              IN  AAAA          ${host.ipv6}
    ''
    ''

      ; VMs
    ''
    (concatStrings (mapAttrsToList (
        vmName: vmData: let
          sub = attrByPath ["subdomain"] vmName vmData;
        in ''
          ${sub}                IN  A             ${host.ipv4}
          ${sub}                IN  AAAA          ${host.ipv6}
          _443._tcp.${sub}      IN  TLSA          3 1 1 ${TLSA}
        ''
      )
      vms))
    ''
      ; Additional
    ''
    (concatMapStrings (sub: ''
        ${sub}                IN  A             ${host.ipv4}
        ${sub}                IN  AAAA          ${host.ipv6}
        _443._tcp.${sub}      IN  TLSA          3 1 1 ${TLSA}
      '')
      ["srv" "mta-sts" "autoconfig" "matrix-federation" "matrix-client"])
    ''

      ; DAV
      _caldav._tcp          IN  SRV           0 0 0 .
      _caldavs._tcp         IN  TXT           "path=/dav"
      _caldavs._tcp         IN  SRV           0 1 443 dav
      _carddav._tcp         IN  SRV           0 0 0 .
      _carddavs._tcp        IN  TXT           "path=/dav"
      _carddavs._tcp        IN  SRV           0 1 443 dav

      ; TLSA
      _443._tcp             IN  TLSA          3 1 1 ${TLSA}
      _25._tcp.mail         IN  TLSA          3 1 1 ${TLSA}
      _465._tcp.mail        IN  TLSA          3 1 1 ${TLSA}
      _993._tcp.mail        IN  TLSA          3 1 1 ${TLSA}

      ; Mail stuff
      @                     IN  HTTPS         1 . alpn=h2,h3
      @                     IN  MX            10 mail
      @                     IN  TXT           "v=spf1 ${spfAddrs} ~all"
      *                     IN  HTTPS         1 . alpn=h2,h3
      *                     IN  TXT           "v=spf1 ${spfAddrs} -all"
      _dmarc                IN  TXT           "v=DMARC1;p=reject;rua=mailto:dmarc-reports@${domain}!10m"
      2024a._domainkey      IN  TXT           "v=DKIM1;h=sha256;k=ed25519;p=M0Gvhf9JeT9QqnlSY492QWKqwOv9MXEfCbXL1n9owoI="
      2024b._domainkey      IN  TXT           "v=DKIM1;h=sha256;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1AYaoSc3XRiUNZgNvZeAZT43KbT0NMuKWtVQI/EC83d144OxcEvtOXreGM/s4IHkOpNEv1HFPvr1WioWUTDN6/hNQTNABeOKOcSfeYyaCaAsoPLz9jVaiwfjqAO5OgiQ+JpmyrQiKpQCws27ww//pshMGpzZlncLaUBZuedtsDQwRPmg1RRBOeCS2+9M08+fLeakzkhAJXQW8XXLhGDTvQC7rzTZuZoaX/JvaXBDidaU4QrMajyuMRnmWb5j4DvZKSirHURKH+dw2B9A+7Kr3LgKpU50591q8C8bBhTrSihu5JyJ/k8kwM457W/xT2QDaSxtt/YO5XkL9qcY3gyltwIDAQAB"
      2024c._domainkey      IN  TXT           "v=DKIM1;h=sha256;k=ed25519;p=TuL5zLOo7jvY/whF1JLCHVQiocD8mMoZmEGFHLrAgmk="
      2024d._domainkey      IN  TXT           "v=DKIM1;h=sha256;p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3AqwiCCQujRTjtBAoWCfwIFDPH8ZM6SxQPvKdiKq6hS48Sddtdk+6dS2PkDcfNx8NHrGN4mzOsdusr/TZ95SjT23CsP8cOUW8EDXhkXyux/RKJEoE5M4sNFW8FxM2vekm16GdUb9UIt7d8cOUJ8qrAUnRgpUgLo0WX3tes6YLyKIfhNilTB9nRiu0irooYZeFx5/sqwyzgXtPV+//rLiMlW24PUhv0PLE1GeQGCGWpe3fF3lFnswerR2gk4AUzCWxXV/C+zUvQVzEwBxMByqITvzrzeFlVHD7uTehEcx1+1u0xmQVtg/1lyHvySBED2FedxaTNI9YB91awuhpfG61QIDAQAB"
      _mta-sts              IN  TXT           "v=STSv1; id=20240901T000625"
      _autodiscover._tcp    IN  SRV           0 1 443 mail
      _imap._tcp            IN  SRV           0 1 143 .
      _imaps._tcp           IN  SRV           0 1 993 mail
      _pop3._tcp            IN  SRV           0 1 110 .
      _pop3s._tcp           IN  SRV           0 1 995 .
      _submission._tcp      IN  SRV           0 1 587 .
      _submissions._tcp     IN  SRV           0 1 465 mail
      _smtp._tls            IN  TXT           "v=TLSRPTv1; rua=mailto:tls-reports@${domain}"
      mail                  IN  TXT           "v=spf1 ${spfAddrs} -all"
      _smtp._tls.mail       IN  TXT           "v=TLSRPTv1; rua=mailto:tls-reports@mail.${domain}"
    ''
  ]
