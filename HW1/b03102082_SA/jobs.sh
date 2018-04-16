#!/usr/bin/env bash

# parsing arg
showList=0
showCpu=0
showMem=0

# help
help() {
    echo "jobs.sh [OPTION...]"
    echo "-l, --list           	listing all grades in descendant order of consuming resource (according to CPU usage first, then memory usage)"
    echo "-m, --mem            	print the usage of memory (in KB)"
    echo "-c, --cpu            	print the usage of CPU (in %)"
    echo "-h, --help           	print this help message"
}

# invalid option
invalid_option () {
    echo "getopt: invalid option -- '"${1}"'"
    help
    exit 1
}

for arg in "$@"; do
    if [ $arg == "-h" ] || [ $arg == "--help" ]; then
        if [ ! $# -eq 1 ]; then
            # -h and --help can only be used alone
            echo "-h and --help can only be used alone"
        fi
        help
        exit 0
    elif [[ ! $arg =~ ^-{1,2}[a-zA-Z]+ ]]; then
        echo "jobs.sh: Extra arguments -- ${arg}"
        echo "Try 'jobs.sh -h' for more information."
        exit 1
    elif [[ $arg =~ ^--[a-zA-Z]+ ]]; then
        arg=${arg//--/}
        # echo $arg
        case "$arg" in
        "list")
            showList=1
            continue
            ;;
        "mem")
            showMem=1
            continue
            ;;
        "cpu")
            showCpu=1
            continue
            ;;
        "help")
            echo "-h and --help can only be used alone"
            invalid_option $arg
            ;;
        *)
            invalid_option $arg
            ;;
        esac
    elif [[ $arg =~ ^-[a-zA-Z]+ ]]; then
        arg=${arg//-/}
        for (( i=0; i<${#arg}; i++ )); do
            char=${arg:$i:1}
            case "${char}" in
            "l")
                showList=1
                continue
                ;;
            "m")
                showMem=1
                continue
                ;;
            "c")
                showCpu=1
                continue
                ;;
            "h")
                echo "-h and --help can only be used alone"
                invalid_option $arg
                ;;
            *)
                invalid_option $arg
                ;;
            esac
        done
    fi
done

# user, cpu, mem(VSZ)
data=$(ps aux | awk '{print $1,$3,$5}' | awk '{
        if($1 ~ /^[brd][0-9]{5}/) {
            $1=substr($1,1,3)
            s1[$1]+=$2; 
            s2[$1]+=$3;
        } 
        else {
            s1[other]+=$2; 
            s2[other]+=$3;
        }
    }END{
        for (k in s1) {
            if(k == "") print "others ",s1[k]," ",s2[k];
            else print k" ",s1[k]," ",s2[k];
        }
    }' | sort -nr -k2,2 -k3,3)

array=()
group_list=()
cpu_list=()
mem_list=()
group_index=1
group_list[0]="GROUP\t"
cpu_list[0]="CPU(%)\t"
mem_list[0]="MEM(KB)"
while read -r line; do
    # split group, cpu, mem into an array
    IFS=' ' read -r -a array <<< "${line}"
    group_list[${group_index}]="${array[0]}\t"
    cpu_list[${group_index}]="${array[1]}\t"
    mem_list[${group_index}]="${array[2]}"

    (( group_index++ ))
done <<< "${data}"

# output
output_line_number=2
if [ $showList -eq 1 ]; then 
    output_line_number=$group_index
fi

if [ $showCpu -eq 0 ]; then
    unset cpu_list
fi

if [ $showMem -eq 0 ]; then
    unset mem_list
fi

for (( i=0; i<$output_line_number; i=i+1)); do
    echo -e "${group_list[$i]}${cpu_list[$i]}${mem_list[$i]}"
done