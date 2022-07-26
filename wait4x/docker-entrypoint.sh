#!/bin/bash
shopt -s extglob

#  parse environment variable to wait4x command param name and value
# environment variable extract param name
# 1. Remove prefix WAIT4X_
# 1.1 if env contains period (.) remove characters after this
# 2. Replace name an underscore (_) with dash (-).
# 3. Lower case
# 
function function_param_parse() {
    
    wait4x_param_name=$1
    wait4x_param_value=$2

    # remove prefix
    wait4x_param_name=${wait4x_param_name//WAIT4X_/}

    if [[ "${wait4x_param_name//./}" != "$wait4x_param_name" ]]; then
        # recreate name remove 
        wait4x_param_name="${NAME//.*/}"
    elif [[ "${wait4x_param_name/%_*([0-9])/}" != "$wait4x_param_name" ]]; then
        # recreate name remove 
        wait4x_param_name="${wait4x_param_name/%_*([0-9])/}"
    fi

    if [[ "${wait4x_param_name:0:3}" = "CMD" ]]; then
        # not param
        wait4x_param_name=""
        wait4x_param_value=""
    else
        # replace
        wait4x_param_name="${wait4x_param_name//_/-}"
        # upper case
        wait4x_param_name="$( echo "$wait4x_param_name" | tr '[:upper:]' '[:lower:]' )"
    fi

    _result_param_name="$wait4x_param_name"
    _result_param_value="$wait4x_param_value"
}


#  generation wait4x command positional parameters 
# 1. Empty value not need append to result
function function_param_generation() {
    
    wait4x_param_name=$1
    wait4x_param_value=$2

    empty_value="false"
    # check value is empty
    [[ "${wait4x_param_value/ /}" = "" ]] && empty_value="true"
    [[ "${wait4x_param_value/:/}" = "" ]] && empty_value="true"

    is_core_cmd=$(echo ${_WAIT4X_COMMAND_ARRAY[@]} | grep -o "$wait4x_param_name" | wc -w)

    # start dash (--) with name
    if [[ -z "$wait4x_param_name" ]]; then
        command_param=""
    elif [[ "$is_core_cmd" == "1" ]]; then
        command_param="$wait4x_param_name"
    else
        command_param="--$wait4x_param_name"
    fi

    # append value if need
    if [[ "$empty_value" != "true" ]]; then
        command_param="$command_param $wait4x_param_value"
    fi

    _result_param="$command_param"
}



#####init_variable

_engine_dir=""
_command_name="wait4x"
WAIT4X_CMD=${WAIT4X_CMD:=bash /docker-deploy.sh}
_WAIT4X_COMMANDS=${_WAIT4X_COMMANDS:=tcp,http,redis,mysql,postgresql,influxdb,mongodb,rabbitmq}


#####begin

IFS=',' read -ra _WAIT4X_COMMAND_ARRAY <<< "$_WAIT4X_COMMANDS"

# create command
_command_opt=
read -r -a _env_array <<< "$( echo "${!WAIT4X_*}" )"
for _env in "${_env_array[@]}"; do
    function_param_parse "$_env" "${!_env}"
    function_param_generation "$_result_param_name" "$_result_param_value"

    if [[ -z "$_command_opt" ]]; then
        _command_opt="$_result_param"
    else
        _command_opt="$_command_opt $_result_param"
    fi
done
_command="$_engine_dir$_command_name $_command_opt -- ${WAIT4X_CMD}"

# print command
echo "$_command"

# run command
echo
if [[ -z "$_log_redirect" ]]; then
    $_command
else
    $_command &> "$_log_redirect"
fi
code=$?

# done command
echo
if [[ $code -eq 0 ]]; then
    echo "Ok, run done"
else
    echo "Sorry, some error '$code' make failure"
fi
