#!/bin/bash

# doubleDigit=$(pmset -g batt | grep [0-9][0-9]% | awk 'NR==1{print $3}' | cut -c 1-3)
#
# if [ ${#doubleDigit} -gt 1 ]; then
# 	echo "$doubleDigit"
# else
# 	doubleDigit=$(pmset -g batt | grep [0-9]% | awk 'NR==1{print $3}' | cut -c 1-2)
# 	echo "$doubleDigit"
# fi

POWERLEVEL9K_BATTERY_CHARGING='yellow'
POWERLEVEL9K_BATTERY_CHARGED='green'
POWERLEVEL9K_BATTERY_DISCONNECTED='$DEFAULT_COLOR'
POWERLEVEL9K_BATTERY_LOW_THRESHOLD='10'
POWERLEVEL9K_BATTERY_LOW_COLOR='red'
POWERLEVEL9K_BATTERY_ICON='\uf1e6'

prompt_zsh_battery_level() {
  local percentage1=`pmset -g ps  |  sed -n 's/.*[[:blank:]]+*\(.*%\).*/\1/p'`
  local percentage=`echo "${percentage1//\%}"`
  local color='%F{red}'
  local symbol="\uf00d"

  pmset -g ps | grep "discharging" > /dev/null

  if [ $? -eq 0 ]; then
    local charging="false";
  else
    local charging="true";
  fi

  if [ $percentage -le 20 ]; then
      #10%
      symbol='\uf579' ; color='%F{red}' ;
  elif [ $percentage -gt 19 ] && [ $percentage -le 30 ]; then
      #20%
      symbol="\uf57a" ; color='%F{red}' ;
  elif [ $percentage -gt 29 ] && [ $percentage -le 40 ]; then
      #35%
      symbol="\uf57b" ; color='%F{yellow}' ;
  elif [ $percentage -gt 39 ] && [ $percentage -le 50 ]; then
      #45%
      symbol="\uf57c" ; color='%F{yellow}' ;
  elif [ $percentage -gt 49 ] && [ $percentage -le 60 ]; then
      #55%
      symbol="\uf57d" ; color='%F{blue}' ;
  elif [ $percentage -gt 59 ] && [ $percentage -le 70 ]; then
      #65%
      symbol="\uf57e" ; color='%F{blue}' ;
  elif [ $percentage -gt 69 ] && [ $percentage -le 80 ]; then
      #75%
      symbol="\uf57f" ; color='%F{blue}' ;
  elif [ $percentage -gt 79 ] && [ $percentage -le 90 ]; then
      #85%
      symbol="\uf580" ; color='%F{blue}' ;
  elif [ $percentage -gt 89 ] && [ $percentage -le 99 ]; then
      #85%
      symbol="\uf581" ; color='%F{blue}' ;
  elif [ $percentage -gt 98 ]; then
      #100%
      symbol="\uf578" ; color='%F{green}' ;
  fi

  if [ $charging = "true" ]; then
      color='%F{green}';

      if [ $percentage -gt 98 ]; then
          symbol='\uf584';
      fi
  fi

  echo -n "%{$color%}$symbol"
}

prompt_battery() {
  # The battery can have four different states - default to 'unknown'.
  local current_state='unknown'
  typeset -AH battery_states
  battery_states=(
    'low'           'red'
    'charging'      'yellow'
    'charged'       'green'
    'disconnected'  "$DEFAULT_COLOR_INVERTED"
  )
  local ROOT_PREFIX="${4}"
  # Set default values if the user did not configure them
  set_default POWERLEVEL9K_BATTERY_LOW_THRESHOLD  10

    # obtain battery information from system
  local raw_data="$(${ROOT_PREFIX}/usr/bin/pmset -g batt | awk 'FNR==2{print}')"
  # return if there is no battery on system
  [[ -z $(echo $raw_data | grep "InternalBattery") ]] && return

  # Time remaining on battery operation (charging/discharging)
  local tstring=$(echo $raw_data | awk -F ';' '{print $3}' | awk '{print $1}')
  # If time has not been calculated by system yet
  [[ $tstring =~ '(\(no|not)' ]] && tstring="..."

  # percent of battery charged
  typeset -i 10 bat_percent
  bat_percent=$(echo $raw_data | grep -o '[0-9]*%' | sed 's/%//')

  local remain=""
  # Logic for string output
  case $(echo $raw_data | awk -F ';' '{print $2}' | awk '{$1=$1};1') in
    # for a short time after attaching power, status will be 'AC attached;'
    'charging'|'finishing charge'|'AC attached')
      current_state="charging"
      remain=" ($tstring)"
      ;;
    'discharging')
      [[ $bat_percent -lt $POWERLEVEL9K_BATTERY_LOW_THRESHOLD ]] && current_state="low" || current_state="disconnected"
      remain=" ($tstring)"
      ;;
    *)
      current_state="charged"
      ;;
  esac

  local message

  message="$bat_percent$remain"
  echo "$message"
}

batteryColors=$(prompt_zsh_battery_level)
batteryLevel=$(prompt_battery)

echo -n "$batteryColors $batteryLevel"
