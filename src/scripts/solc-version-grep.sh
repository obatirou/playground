#! /bin/bash

cast --to-uint256 $(solc --version | tr -d '\n' | grep -q 0.8.16; echo $? | tr -d '\n')