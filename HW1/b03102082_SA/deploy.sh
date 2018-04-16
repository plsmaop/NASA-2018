#!/usr/bin/env bash

# ussage
# ./deploy.sh [username] [private key] [command] or ./deploy.sh [username] [command]
# the 1th command login with ssh key, while the 2nd one login with password
# if you want to login with ssh key, please make sure that you have already ssh-copy-id the corresponding public key to all workstations

# parsing arg
arg_array=()
arg_iterator=0
for tmp_arg in "$@"
do
    arg_array[${arg_iterator}]="${tmp_arg}"
    (( arg_iterator++ ))
done

LoginWithKey=0
# checking whether the 2nd arg is a ssh key
if [ -e "${arg_array[1]}" ]; then
    user=${arg_array[0]}
    key=${arg_array[1]}
    command=${arg_array[2]}
    LoginWithKey=1
    # echo "login with ssh key"
    # ssh-agent adding key
    eval $(ssh-agent) ssh-add ${key}  
else
    user=${arg_array[0]}
    command=${arg_array[1]}
fi

# treating other arguments as optional flags or args of the [command]
if [ ${LoginWithKey} -eq 1 ]; then
    args_index=3
else 
    args_index=2
fi

for(( i=$args_index; i<$#; i=i+1 ))
do 
    arg+=" "
    arg+=${arg_array[$i]}
done



# deploy
do_command="${command} ${arg}; exit;"
for(( i=1; i <= 19; i=i+1 ))
do
    server="linux${i}"

    case "${i}" in
        "16")
            server="oasis1"
            ;;
        "17")
            server="oasis2"
            ;;
        "18")
            server="oasis3"
            ;;
        "19")
            server="bsd1"
            ;;
    esac
    # add server to known host
    IP="${server}.csie.ntu.edu.tw"
    if [ -z $(ssh-keygen -F "$IP" | head -n 1 | cut -d " " -f 1 ) ]; then
        ssh-keyscan -H $IP >> ~/.ssh/known_hosts
    fi

    login="${user}@${IP}"
    echo "======== ${server} ========"

    # ssh-copy-id -i "${key}.pub" -o StrictHostKeyChecking=no -f  "${login}" >&- 2>&-
    if [ ${LoginWithKey} -eq 1 ]; then
        ssh -i "${key}"  "${login}" "${do_command}"
    else
        ssh -o PubkeyAuthentication=no "${login}" "${do_command}"
    fi
    echo "========================"
done

# remove key
if [ ${LoginWithKey} -eq 1 ]; then
    ssh-add -d "${key}" 
fi
