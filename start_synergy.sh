#!/bin/bash -e
#
# Script to start/restart synergy on two hosts using a secure ssh tunnel.
# Author: waudet@gmail.com (Wolf Audet)
####
# Edit the three variables bellow to match your setup.
####
declare -r CLIENT='client_ip'
declare -r HOST='host_ip'
declare -r SYNERGY_CONF='/path/to/.synergy.conf'
####

declare -r CURRENT_HOST="${HOSTNAME}"
declare -r PKILL_REGEX='[s]ynergys -a 127|[s]ynergyc local|[2]4800:localhost:'

host_side_start() {
  nohup synergys -a 127.0.0.1 -c "${SYNERGY_CONF}"
  nohup ssh -NR 24800:localhost:24800 "${CLIENT}" &
  ssh "${CLIENT}" 'nohup synergyc localhost'
}

client_side_start() {
  ssh "${HOST}" "nohup synergys -a 127.0.0.1 -c \"${SYNERGY_CONF}\""
  nohup ssh -NXL 24800:localhost:24800 "${HOST}" &
  nohup synergyc localhost || echo 'synergyc failed'
}

if [[ "${CURRENT_HOST}" == "${HOST}" ]]; then
  ssh "${CLIENT}" "pkill -f \"${PKILL_REGEX}\"" || true &
  pkill -f "${PKILL_REGEX}" || true &
  wait
  host_side_start
elif [[ "${CURRENT_HOST}" == "${CLIENT}" ]]; then
  ssh "${HOST}" "pkill -f \"${PKILL_REGEX}\"" || true &
  pkill -f "${PKILL_REGEX}" || true &
  wait
  client_side_start
fi

echo 'done' && exit
