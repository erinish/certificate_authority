This package contains your SSL/TLS Bundle.

Included are the following files:

1. A copy of the Certificate Request (CSR), named ##DOMAIN##.csr

2. The private key used to generate the original request, ##DOMAIN##.key

3. The signed certificate in PEM format, ##DOMAIN##.crt

4. A copy of the Intermediate and Root Authority, collectively a Chain Certificate, ca-chain.crt

5. A pre-formatted Chain + Certificate for use in web servers such as Nginx, ##DOMAIN##-nginx.crt

6. A pre-compiled PKCS12, ##DOMAIN##.p12. The password for this p12 is ##PASSWORD##

7. A pre-compiled JKS (Java Keystore), ##DOMAIN##.jks. The password for this JKS is ##PASSWORD##