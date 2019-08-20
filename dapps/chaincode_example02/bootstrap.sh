#!/bin/bash

CRYPTO_MATERIALS_SRC="../../network/minimal/crypto"
CRYPTO_MATERIALS_DST="./crypto"

if [ -e ${CRYPTO_MATERIALS_SRC} ]; then
  rm -rf ${CRYPTO_MATERIALS_DST}
  cp -avR ${CRYPTO_MATERIALS_SRC} ${CRYPTO_MATERIALS_DST}
fi

is_peer1_on_etc_hosts=`grep "peer1.org1" /etc/hosts | wc -l`
if [ $is_peer1_on_etc_hosts -eq 1 ]; then
  echo "peer1.org1 is registered on /etc/hosts"
else
  echo "127.0.0.1 peer1.org1" >> /etc/hosts
fi

is_orderer1_on_etc_hosts=`grep "orderer1.ordererorg" /etc/hosts | wc -l`
if [ $is_orderer1_on_etc_hosts -eq 1 ]; then
  echo "orderer1.ordererorg is registered on /etc/hosts"
else
  echo "127.0.0.1 orderer1.ordererorg" >> /etc/hosts
fi
