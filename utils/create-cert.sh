#!/usr/bin/env sh
# args:
# $1: common name
# $2: out path

mkdir /tmp/create-cert.sh
cd /tmp/create-cert.sh

nix-shell -p --run "step ca certificate $1.invalid cert.pem key.pem --ca-url https://certs.vm.cynosure.red --root /etc/ssl/domain-ca.crt --not-after=8760h"

openssl pkcs12 -export -name "$1 cert/key" -out $2 -inkey key.pem -in cert.pem

rm -rf /tmp/create-cert.sh
