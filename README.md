# asn-tools

A collection of scripts to automate BGP filter creation on a ubiquti EdgeOS (and VyOS/Vyatta).

In this repo included are:

`confgen.rb` - generates router configuration based on the config file

`whoisgen.rb` - generates import/export rules for the RIPE whois database.


## Example config file

```
---
config:
  ouras: 31337
router:
  rtr1:
    model: vyatta
    upstream:
      42:
        name: ACME Inc.
        community: 1001
        ipv4:
          import: ANY
          export: AS-ELITE
          local-ip: 1.2.3.4
          remote-ip: 42.42.42.42
          interface: exchange
        ipv6:
          import: ANY
          export: AS-ELETE
          local-ip: 2000:1234::1
          remote-ip: 2000:1234::2
          interface: exchange
    peering:
      666:
        community: 3666
        name: HELL Inc.
        ipv4:
          import: AS-HELL
          export: AS-ELETE
          local-ip: 1.2.3.4
          remote-ip: 6.6.6.6
          interface: exchange
          maximum-prefix: 500
          password: Secret
        ipv6:
          import: AS-HELL
          export: AS-ELETE
          local-ip: 2000:1234::1
          remote-ip: 2000:1234::666
          interface: exchange
          maximum-prefix: 100
          password: Secret
```

## Generating rules

`confgen.rb -t peering -a 666 -r rtr1`

## Generating whois entries for RIPEDB

`whoisen.rb`

