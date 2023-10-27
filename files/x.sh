#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


function print_green() {
  printf "${GREEN}%s${NC}\n" "$1"
}

function print_red() {
  printf "${RED}%s${NC}\n" "$1"
}

function print_blue() {
  printf "${BLUE}%s${NC}\n" "$1"
}

# The sed commend with system judging
# Examples:
# sed -i 's/a/b/g' bob.txt => x_sed 's/a/b/g' bob.txt
function x_sed() {
  system=$(uname)

  if [ "${system}" = "Linux" ]; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

# The path of axiom-ledger project on the target machine
export AXIOM_LEDGER_PROJECT_PATH="/home/hyperchain/code/axiomesh/axiom-ledger"
# The path of axiom-ledger binary on the target machine
export AXIOM_LEDGER_BINARY_PATH="/home/hyperchain/go/bin/axiom-ledger"

# target machine sudo password
export PASSWORD="hyperchain"

# chaosblade config
export CHAOSBLADE_PATH="/home/hyperchain/tools/chaosblade-1.7.2"