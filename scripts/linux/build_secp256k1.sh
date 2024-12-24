# This script is provided in case `dart run coinlib:build_linux` fails.
#
# Adapted from Stack Wallet's secp256k1 build script. See
# https://github.com/cypherstack/stack_wallet/tree/staging/scripts for scripts for additional
# platforms.

mkdir -p build
cd build
if [ ! -d "secp256k1" ]; then
    git clone https://github.com/bitcoin-core/secp256k1
fi
cd secp256k1
git checkout 68b55209f1ba3e6c0417789598f5f75649e9c14c
git reset --hard
mkdir -p build && cd build
cmake ..
cmake --build .
echo "$PWD"
cp lib/libsecp256k1.so.2.2.2 "../../libsecp256k1.so"
cd ../../
