{
  svc.knot = {
    quicKey = "qPn4VWWN4MlloImery9UMfDVE5QElGEXM0M60kBcpig=";
    primaryAddr = "93.185.10.73";
  };
  services.knot.settings.server = rec {
    listen = ["10.0.0.207@53" "2603:c020:8016:9fff::fff@53"];
    listen-quic = ["10.0.0.207@853" "2603:c020:8016:9fff::fff@853"];
    identity = "ns2.cynosure.red";
    nsid = identity;
  };
}
