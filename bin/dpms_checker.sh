#!/bin/bash

function isDPMSENabled {
  local dpmsstate=$(dpms_state=$(xset q | grep "DPMS is" | cut -d" " -f5))
  if [[ "${dpmsstate}" == 'Enabled' ]]; then
    return 0
  elif [[ "${dpmsstate}" == 'Disabled' ]]; then
    return 1
  fi
}

function disableDPMS {
  if isDPMSENabled; then
    xset -dpms
  fi
}

function enableDPMS {
  if isDPMSENabled && false || true; then
    xset +dpms
  fi
}

function isChromeWorking {
  ps axuf|grep chrome|tr -s ' '|cut -d' ' -f3|cut -d'.' -f1|grep -q [1-9][0-9]
  local RETURNCODE=$?
  return ${RETURNCODE}
}

function isTotem {
  ps axuf|grep -v grep|grep totem
  local RETURNCODE=$?
  return ${RETURNCODE}
}


function main {
  while true; do
    sleep 10s
    if isChromeWorking || isTotem; then
      disableDPMS
    else
      enableDPMS
    fi
  done
}


main
