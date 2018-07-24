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

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD
