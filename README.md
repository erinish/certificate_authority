Certificate Authority
=========

Adds a locally-trusted Certificate Authority and associated helper scripts to simplify creating internal certificates.

Requirements
------------

Designed and tested on CentOS 7. Requires OpenSSL.

Role Variables
--------------

```YAML
ca_base_dir: /root/ca
ca_common_name: "Example Co Root CA"
ca_country_name: "US"
ca_state_or_province_name: "New York"
ca_organization_name: "Example Co"
ca_valid_days: 18250
inter_ca_common_name: "Example Co Intermediate CA"
inter_ca_country_name: "US"
inter_ca_state_or_province_name: "New York"
inter_ca_organization_name: "Example Co"
inter_ca_valid_days: 16425
```


Example Playbook
----------------
```YAML
---
- name: local CA role application
  hosts: phylactery
  roles:
    - role: erinish.certificate_authority
      ca_common_name: "Hollywoo Root CA"
      ca_state_or_province_name: "California"
      ca_organization_name: "Hollywoo"
      inter_ca_common_name: "Hollywoo Intermediate CA"
      inter_ca_state_or_province_name: "California"
      inter_ca_organization_name: "Hollywoo"
```
License
-------

MIT
