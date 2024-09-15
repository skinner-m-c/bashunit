#!/bin/bash

function clock::now() {

  if dependencies::has_perl && perl -MTime::HiRes -e "" > /dev/null 2>&1; then
    if perl -MTime::HiRes -e 'printf("%.0f\n",Time::HiRes::time()*1000000000)'; then
      return 0
    fi
  fi

  if  dependencies::has_adjtimex && check_os::is_busybox && dependencies::has_awk; then
    # adjtimex has more precise time on busybox than the date command, which does not support nanoseconds

    if get_adjtimex_time; then
          return 0
    fi
  fi

  if [[ "$_OS" != "OSX" ]]; then
    local date_cmd_time

    date_cmd_time=$(date +%s%N)

     if [[ "$?" -ne 0 ]]; then
              return 1
     fi

    if check_os::is_busybox; then
      math::calculate "($date_cmd_time * 1000000000)"
    else
      echo "$date_cmd_time"
    fi

     return 0
  fi

  echo ""
  return 1

}


function get_adjtimex_time() {
  # Sometimes adjtimex returns times that are one magnitude lower than normal for some reason. So we have to
  # keep asking for the time until we get a time of sufficient size.

  local adjtimex_time
  local start_time

   start_time=$(date +%s)

     while
      adjtimex_time=$(adjtimex | awk '/(time.tv_sec|time.tv_usec):/ { printf("%06d", $2) }')

      if [[ "$?" -ne 0 ]]; then
        return 1
      fi

      if [[ "$adjtimex_time" -gt 999999999999999999 ]]; then
        break
      fi

      if [[ $(math::calculate "($(date +%s) - $start_time)") -gt 1 ]]; then
        echo "break" >> break.txt
        break
      fi


     do true; done
   echo "$adjtimex_time"

}


_START_TIME=$(clock::now)

function clock::runtime_in_milliseconds() {
  end_time=$(clock::now)
  if [[ -n $end_time ]]; then
    math::calculate "($end_time-$_START_TIME)/1000000"
  else
    echo ""
  fi
}

function clock::runtime_in_nanoseconds() {
  end_time=$(clock::now)
  if [[ -n $end_time ]]; then
    math::calculate "($end_time-$_START_TIME)"
  else
    echo ""
  fi
}


function clock::readable_duration {
    local nanosecond_time=$1
    local readable_duration_value;

    local microsecond_time=$((nanosecond_time/ 1000))
    local us=$((microsecond_time % 1000))
    local ms=$(((microsecond_time / 1000) % 1000))
    local s=$(((microsecond_time / 1000000) % 60))
    local m=$(((microsecond_time / 60000000) % 60))
    local h=$((microsecond_time / 3600000000))

    if ((h > 0)); then
      readable_duration_value=${h}h${m}m
    elif ((m > 0)); then
      readable_duration_value=${m}m${s}s
    elif ((s >= 10)); then
      readable_duration_value=${s}.$((ms / 100))s
    elif ((s > 0)); then
      readable_duration_value=${s}.$(printf %03d $ms)s
    elif ((ms >= 100)); then
      readable_duration_value=${ms}ms
    elif ((ms > 0)); then
      readable_duration_value=${ms}.$((us / 100))ms
    else
      readable_duration_value=${us}us
    fi
    echo "$readable_duration_value"
}
