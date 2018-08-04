This package contains your SSL/TLS Bundle.

Included are the following files:

- A copy of the Certificate Request (CSR), named ##DOMAIN##.csr

- The private key used to generate the original request, ##DOMAIN##.key

- The signed certificate in PEM format, ##DOMAIN##.crt

- A copy of the Intermediate and Root Authority, collectively a Chain Certificate, ca-chain.crt

- A pre-formatted Chain + Certificate for use in web servers such as Nginx, ##DOMAIN##-nginx.crt

- A pre-compiled PKCS12, ##DOMAIN##.p12. The password for this p12 is ##PASSWORD##

- A pre-compiled JKS (Java Keystore), ##DOMAIN##.jks. The password for this JKS is ##PASSWORD##
