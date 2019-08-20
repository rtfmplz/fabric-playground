#!/bin/bash

#########################################################
# Variables
#########################################################
CRYPTO_MATERIALS_SRC="../../network/minimal/crypto"
CRYPTO_MATERIALS_DST="./crypto"


#########################################################
# Copy crypto materials
#########################################################
if [ -e ${CRYPTO_MATERIALS_SRC} ]; then
  rm -rf ${CRYPTO_MATERIALS_DST}
  cp -avR ${CRYPTO_MATERIALS_SRC} ${CRYPTO_MATERIALS_DST}
fi

