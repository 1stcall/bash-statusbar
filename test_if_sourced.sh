#!/usr/bin/env bash
script_name=$( basename "${0#-}" ) #- needed if sourced no path
this_script=$( basename "${BASH_SOURCE[0]}" )
if [[ ${script_name} = "${this_script}" ]] ; then
    echo "${this_script} is running directly"
else
    echo "${this_script} sourced from ${script_name}"
fi 