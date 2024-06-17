#!/bin/bash

set +x

PROG=$1

echo "building and running ${PROG}..."

gcc ${PROG}.c \
	-lpthread -ldl -lm \
	-L../wasmtime-v21.0.1-x86_64-linux-c-api/lib -lwasmtime \
	-I../wasmtime-v21.0.1-x86_64-linux-c-api/include \
	-o ${PROG}
LD_LIBRARY_PATH=../wasmtime-v21.0.1-x86_64-linux-c-api/lib ./${PROG}
