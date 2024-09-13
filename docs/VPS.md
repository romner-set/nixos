Each VPS hosts (so far):
 - ~~a [rathole](https://github.com/rapiz1/rathole) instance for NAT traversal~~ - disabled since main server no longer behind NAT
 - a KnotDNS secondary server for https://cynosure.red

It's also worth noting that the VPSs are considered completely untrusted, so they only proxy already encrypted web traffic at the TCP level and publish records DNSSEC-signed by the trusted main server (to whose hardware I have physical access to).

### Deploying a new VPS
Mostly a personal guide for convenience, should work for anyone trying to use this config though. NOTE: since this flake is so huge, the VPS will need a lot of RAM to build it. Swap is included after installation to remedy this, but for the first install you may need to temporarily rescale the VM.

1. Boot into an installer using kexec (https://github.com/nix-community/nixos-images), make sure an SSH key is set in `/root/.ssh/authorized_keys`.
   This only works for ARM machines, use the one in the linked README for x86
   ```sh
   curl -L https://github.com/nix-community/nixos-images/releases/download/nixos-unstable/nixos-kexec-installer-noninteractive-aarch64-linux.tar.gz | tar -xzf- -C /root
   /root/kexec/run
   ```
   SSH into the new system afterwards, then install git:
   ```sh
   nix-channel --update
   nix-shell -p git
   ```

2. Format & mount persistent storage, install system
   ```sh
   hostname=REPLACEME

   nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake "git+https://git.cynosure.red/romner-set/nixos#$hostname"
   nixos-install --no-root-passwd --flake "git+https://git.cynosure.red/romner-set/nixos#$hostname"
   ```
3. ~~Manually create `/mnt/data/rathole.toml` according to this template~~:
   ```toml
   [server]
   bind_addr = "[::]:444"

   [server.transport]
   type = "noise"
   [server.transport.noise]
   pattern = "Noise_KK_25519_ChaChaPoly_BLAKE2s"
   local_private_key = "REPLACEME" # created with `rathole --genkey`
   remote_public_key = "kAucMFPz3+2RP+LTQ6X/LjBcIlmjQ+r8/vBtKe9NfWM=" # main server's pubkey

   [server.services.doq]
   type = "udp"
   token = "REPLACEME"
   bind_addr = "[::1]:853"
   [server.services.http]
   token = "REPLACEME"
   bind_addr = "[::]:80"
   [server.services.https]
   token = "REPLACEME"
   bind_addr = "[::]:443"
   [server.services.http3]
   type = "udp"
   token = "REPLACEME"
   bind_addr = "[::]:443"
   ```

4. Setup `/data` & reboot
   ```sh
   cd /mnt/data
   #chmod 600 rathole.toml # see 3.
   mkdir knot && chown 999:999 knot
   reboot
   ```
5. Update main server, i.e.
   1. Create new rathole keys & client config
   2. Authorize the VPS' `knotc status cert-key`
6. Do something productive (or not) with the time you've just saved
