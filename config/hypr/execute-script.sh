#!/bin/sh

_status_path="$HOME/.config/hypr/status.ini"
_scripts_path="$HOME/.config/hypr/scripts"
_all_script_names=$(ls "$HOME/.config/hypr/scripts" | grep ".sh" | grep -v "execute.sh" | sed 's/.sh//')

_help_page="Usage: execute-script.sh [OPTIONS] [SCRIPT_NAME]
Options:
\t-h - Display help page.
\t-s - Start, executes scripts without changing their values.
\t-a - All, execute all scripts. Should be used with -s. Won't need SCRIPT_NAME.
\t-r - Reset, resets the status.ini file to default values before executing scripts.\n"

_toggle_status() {
  if [[ "$_status" == "1" ]]; then
    _status="0"
  elif [[ "$_status" == "0" ]]; then
    _status="1"
  fi
}

_execute_script() {
  _dashed="_$1"
  _status="${!_dashed}"
  source "$HOME/.config/hypr/scripts/$1.sh"
}


_start=0
_all=0
_reset=0
while getopts 'sah' OPTION; do
  case "$OPTION" in
    h)
    printf "$_help_page"
    exit 0
    ;;
    s)
    _start=1
    ;;
    a)
    _all=1
    ;;
    r)
    _reset=1
    ;;
  esac
done


if [[ "$_reset" == "1" ]] || [[ ! -e $_status_path ]]; then
  cp "$_scripts_path/defaults.ini" "$_status_path"
  _start=1
fi
source <(grep = "$_status_path")


if [[ "$_all" == "1" ]]; then
  for _script_name in $_all_script_names; do
    _execute_script "$_script_name"
    if [[ "$_start" == "0" ]]; then
      declare "_$_script_name=$_status"
    fi
  done
else
  _execute_script "${@: -1}"
  if [[ "$_start" == "0" ]]; then
    declare "_${@: -1}=$_status"
  fi
fi


if [[ "$_start" == "0" ]]; then
  for _script_name in $_all_script_names; do
    _script_dashed="_$_script_name"
    _command="$_command$_script_dashed=${!_script_dashed}\n"
  done
  printf "$_command" > "$_status_path"
fi
