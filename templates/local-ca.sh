#!/bin/bash

HOMEDIR={{ ca_base_dir }}/

# Check for Java Keytool
java_keytool=$(which keytool)

function usage() {
cat << EOF
USAGE: $0 sign <file> | gen <domain1> [domain2] [domain3] ...  

    sign    sign a CSR
    gen     generate a full certificate bundle

EOF
exit 0
}

if [ $# -lt 1 ]; then
    usage
fi

function dir_exists() {
if [[ -d $1 ]]; then
    echo "Directory $1 already exists . . . somehow. Bad luck on that collision. Run the script again, and things will be fine. Probably."
    exit 1
fi
}

function mk_readme() {

    homedir=$1
    domain=$2
    pass=$3
    bundledir=$4

    cp ${homedir}readme.txt ${bundledir}
    sed -i "s/##DOMAIN##/${domain}/g" ${bundledir}readme.txt
    sed -i "s/##PASSWORD##/${pass}/g" ${bundledir}readme.txt

}

function mk_readme_nokey() {

    homedir=$1
    domain=$2
    bundledir=$3

    cp ${homedir}readme-nokey.txt ${bundledir}readme.txt
    sed -i "s/##DOMAIN##/${domain}/g" ${bundledir}readme.txt

}

function sign_csr() {
    FILE=$1
    DOMAIN=$(openssl req -in ${FILE} -subject -noout | grep -o CN=.* | cut -c 4-)
    DNSNAMES=$(openssl req -in ${FILE} -text | grep DNS | awk -F "," 'BEGIN { OFS="\n" }; { $1=$1; print $0 }' | sed "s/^ *//" | awk -F ":" '{ print $2 }')
    i=0
    altnames=""

    if [[ ${DNSNAMES} == "" ]]; then
        DNSNAMES=${DOMAIN}
    fi


    echo -n "Use ${DOMAIN} as domain name[Y/n]"
    read ANS
    case ${ANS} in
    Y)
        ;;
    y)
        ;;
    N)
        echo -n "Input domain: "
        read DOMAIN
	DNSNAMES=${DOMAIN}
	DOMAIN=$(echo ${DOMAIN} | cut -f1 -d " ")
        ;;
    n)
        echo -n "Input domain: "
        read DOMAIN
	DNSNAMES=${DOMAIN}
	DOMAIN=$(echo ${DOMAIN} | cut -f1 -d " ")
        ;;
    *)
        echo "unknown option"
        exit 1
        ;;
    esac


    echo ${DNSNAMES}
    echo -n "DNS names OK?[Y/n]"
    read ANS
    case ${ANS} in
    Y)
        ;;
    y)
        ;;
    N)
        echo "Bailing out"
        exit 1
        ;;
    n)
        echo "Bailing out"
        exit 1
        ;;
    *)
        echo "unknown option"
        exit 1
        ;;
    esac

    for name in $DNSNAMES
        do
        i=$((i + 1))
        line="DNS.${i} = ${name}\n"
        altnames="${altnames}${line}"
        done
    curdate=$(date +%Y-%m-%d)
    bundledir="${HOMEDIR}intermediate/bundles/${DOMAIN}-${curdate}-${randhash}/"
    dir_exists ${bundledir}

    openssl ca -batch -config <(sed "s/##ALTNAMES##/${altnames}/g" ${HOMEDIR}intermediate/openssl.cnf) -extensions server_cert -extensions v3_req -days 3650 -notext -md sha256 -in ${FILE} -out ${HOMEDIR}intermediate/certs/${DOMAIN}-${randhash}.crt
    echo "making directory: ${bundledir}"
    mkdir -p ${bundledir}

    mk_readme_nokey ${HOMEDIR} ${DOMAIN} ${bundledir}
    cp ${FILE} ${bundledir}/$DOMAIN.csr
    cp ${HOMEDIR}intermediate/certs/$DOMAIN-${randhash}.crt ${bundledir}$DOMAIN.crt
    cp ${HOMEDIR}intermediate/certs/ca-chain.crt ${bundledir}ca-chain.crt
    cat ${bundledir}/$DOMAIN.crt > ${bundledir}/$DOMAIN-nginx.crt
    cat ${bundledir}/ca-chain.crt >> ${bundledir}/$DOMAIN-nginx.crt
    exit 0
}


function gen_certs() {
    DOMAIN=$1
    curdate=$(date +%Y-%m-%d)
    bundledir="${HOMEDIR}intermediate/bundles/${DOMAIN}-${curdate}-${randhash}/"
    PASSWORD=$(openssl rand -hex 6)
    dir_exists ${bundledir}
    openssl genrsa -out ${HOMEDIR}intermediate/private/$DOMAIN-${randhash}.key 4096

    openssl req -new -key ${HOMEDIR}intermediate/private/$DOMAIN-${randhash}.key -sha256 -nodes -subj "/C={{ ca_country_name }}/ST={{ ca_state_or_province_name }}/O={{ ca_organization_name }}/CN=$DOMAIN" -config <(sed "s/##ALTNAMES##/${altnames}/g" ${HOMEDIR}intermediate/openssl.cnf) > ${HOMEDIR}intermediate/reqs/$DOMAIN-${randhash}.csr
    openssl ca -batch -config <(sed "s/##ALTNAMES##/${altnames}/g" ${HOMEDIR}intermediate/openssl.cnf) -extensions server_cert -extensions v3_req -days 3650 -notext -md sha256 -in ${HOMEDIR}intermediate/reqs/$DOMAIN-${randhash}.csr -out ${HOMEDIR}intermediate/certs/$DOMAIN-${randhash}.crt

    mkdir -p ${bundledir}
    mk_readme ${HOMEDIR} ${DOMAIN} ${PASSWORD} ${bundledir}
    cp ${HOMEDIR}intermediate/reqs/$DOMAIN-${randhash}.csr ${bundledir}$DOMAIN.csr
    cp ${HOMEDIR}intermediate/private/$DOMAIN-${randhash}.key ${bundledir}$DOMAIN.key
    cp ${HOMEDIR}intermediate/certs/$DOMAIN-${randhash}.crt ${bundledir}$DOMAIN.crt
    cp ${HOMEDIR}intermediate/certs/ca-chain.crt ${bundledir}ca-chain.crt
    cat ${bundledir}$DOMAIN.crt > ${bundledir}$DOMAIN-nginx.crt
    cat ${bundledir}ca-chain.crt >> ${bundledir}$DOMAIN-nginx.crt
    cd ${bundledir}
    openssl pkcs12 -export -in $DOMAIN.crt -inkey $DOMAIN.key -chain -CAfile ${bundledir}ca-chain.crt -out $DOMAIN.p12 -name $DOMAIN -password pass:${PASSWORD}
    if [[ ${java_keytool} != "" ]]; then
        ${java_keytool} -importkeystore -srckeystore ${DOMAIN}.p12 -srcstoretype pkcs12 -srcalias ${DOMAIN} -destkeystore ${DOMAIN}.jks -deststoretype jks -deststorepass ${PASSWORD} -destalias ${DOMAIN}
    fi
}

## Deal with OPTS

case $1 in

sign)
    shift
    randhash=$(openssl rand -hex 4)
    sign_csr $1 ${randhash}
    exit 0
    ;;
gen)
    shift
    randhash=$(openssl rand -hex 4)
    DOMAIN=$1
    i=0
    altnames=""
    while [[ "$1" ]]; do
        i=$((i + 1))
        line="DNS.${i} = $1\n"
        altnames="${altnames}${line}"
        shift
    done
    gen_certs ${DOMAIN} ${altnames} ${randhash}
    exit 0
    ;;
*)
    echo "Unknown command"
    exit 0
    ;;
esac
