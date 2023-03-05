#! /bin/bash

cast abi-encode "f(bytes)" $(solc src/snippets/EmptyContractWithConstructor.sol --bin-runtime --optimize --optimize-runs 200 | tail -1)