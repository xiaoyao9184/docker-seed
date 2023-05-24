#!/bin/bash
shopt -s extglob

#  parse environment variable to dockerize command param name and value
# environment variable extract param name
# 1. Remove prefix DOCKERIZE_
# 1.1 if env contains period (.) remove characters after this
# 1.2 if env endwith underscore (_) with number remove endwith
# 2. Replace name an underscore (_) with dash (-).
# 3. Lower case
# 
function function_param_parse() {
    
    dockerize_param_name=$1
    dockerize_param_value=$2

    # remove prefix
    dockerize_param_name=${dockerize_param_name//DOCKERIZE_/}

    if [[ "${dockerize_param_name//./}" != "$dockerize_param_name" ]]; then
        # recreate name remove 
        dockerize_param_name="${dockerize_param_name//.*/}"
    elif [[ "${dockerize_param_name/%_*([0-9])/}" != "$dockerize_param_name" ]]; then
        # recreate name remove 
        dockerize_param_name="${dockerize_param_name/%_*([0-9])/}"
    fi

    if [[ "${dockerize_param_name:0:3}" = "CMD" ]]; then
        # not param
        dockerize_param_name=""
        dockerize_param_value=""
    else
        # replace
        dockerize_param_name="${dockerize_param_name//_/-}"
        # upper case
        dockerize_param_name="$( echo "$dockerize_param_name" | tr '[:upper:]' '[:lower:]' )"
    fi

    _result_param_name="$dockerize_param_name"
    _result_param_value="$dockerize_param_value"
}


#  generation dockerize command positional parameters 
# 1. Empty value not need append to result
function function_param_generation() {
    
    dockerize_param_name=$1
    dockerize_param_value=$2

    empty_value="false"
    # check value is empty
    [[ "${dockerize_param_value/ /}" = "" ]] && empty_value="true"
    [[ "${dockerize_param_value/:/}" = "" ]] && empty_value="true"

    # start dash (-) with name
    if [[ -z "$dockerize_param_name" ]]; then
        command_param=""
    else
        command_param="-$dockerize_param_name"
    fi

    # append value if need
    if [[ "$empty_value" != "true" ]]; then
        command_param="$command_param $dockerize_param_value"
    fi

    _result_param="$command_param"
}



#####init_variable

_engine_dir=""
_command_name="dockerize"
DOCKERIZE_CMD=${DOCKERIZE_CMD:=bash /docker-deploy.sh}


#####begin

# create command
_command_opt=
read -r -a _env_array <<< "$( echo "${!DOCKERIZE_*}" )"
for _env in "${_env_array[@]}"; do
    function_param_parse "$_env" "${!_env}"
    function_param_generation "$_result_param_name" "$_result_param_value"

    if [[ -z "$_command_opt" ]]; then
        _command_opt="$_result_param"
    else
        _command_opt="$_command_opt $_result_param"
    fi
done
_command="$_engine_dir$_command_name $_command_opt ${DOCKERIZE_CMD}"

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
