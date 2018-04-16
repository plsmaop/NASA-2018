#!/usr/bin/env bash

# Usage: ./lottery.sh [the file of winning numbers] [the file of receipt numbers]

# parsing arg
winning_number_file="${1}"
receipt_file="${2}"

# parsing winning number
winning_array=()
iterator=0

while read -r line || [[ -n "$line" ]]; do
    winning_array[$iterator]="$line"
    (( iterator++ ))
done < "${winning_number_file}"

# checking receipt
receipt_index=0
valid=0
winning=0
money=0
winning_receipt=()
while read -r raw_line || [[ -n "$raw_line" ]]; do
    (( receipt_index++ ))
    # validity
    if [[ ${raw_line} != [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] &&
    [[ ${raw_line} != [A-Za-z][A-Za-z]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]] &&
    [[ ${raw_line} != [A-Za-z][A-Za-z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ]]; then
        continue
    fi

    (( valid++ ))
    line=$( echo "${raw_line}" | sed 's/[A-Za-z][A-Za-z]-*//g' )
    # echo ${line}
    # checking
    for(( i=0; i < iterator; i=i+1 ))
    do
        winning_number=${winning_array[$i]}
        case "${i}" in
            # special prize
            "0")
                if [[ ${line} == "${winning_number}" ]]; then
                    winning_receipt[$winning]="${raw_line} (${receipt_index}) \$10000000"
                    (( winning++ ))
                    (( money+=10000000 ))
                    break
                fi
                ;;
            # grand prize
            "1")
                if [[ ${line} == "${winning_number}" ]]; then
                    winning_receipt[$winning]="${raw_line} (${receipt_index}) \$2000000"
                    (( winning++ ))
                    (( money+=2000000 ))
                    break
                fi
                ;;
            # 1-6th prize
            [2-4])
                partial_number="${winning_number}"
                for(( prize=1; prize<=6; prize=prize+1 ))
                do
                    # echo ${partial_number}
                    # .th prize
                    prize_money=0
                    case "${prize}" in
                    "1")
                        prize_money=200000
                        ;;
                    "2")
                        prize_money=40000
                        ;;
                    "3")
                        prize_money=10000
                        ;;
                    "4")
                        prize_money=4000
                        ;;
                    "5")
                        prize_money=1000
                        ;;
                    "6")
                        prize_money=200
                        ;;
                    esac

                    if [[ ${line} =~ .*"$partial_number"$ ]]; then
                        winning_receipt[$winning]="${raw_line} (${receipt_index}) \$${prize_money}"
                        (( winning++ ))
                        (( money+=prize_money ))
                        break
                    fi
                    partial_number=$( echo $partial_number | sed 's/^[0-9]//g')
                done
                ;;
            # additional sixth prize
            [4-7])
                # echo  ${winning_number}
                if [[ ${line} =~ [0-9]{5}"${winning_number}"$ ]]; then
                    winning_receipt[$winning]="${raw_line} (${receipt_index}) \$200"
                    (( winning++ ))
                    (( money+=200 ))
                    break
                fi
                ;;
        esac
    done
done < "${receipt_file}"

# print
echo "The number of receipts: ${receipt_index}"
echo "The number of valid receipts: ${valid}"
echo "The number of winning lotteries: ${winning}"
echo "The winning money: ${money}"
echo "Winning Lotteries:"

index=0
for receipt in "${winning_receipt[@]}"
do
    (( index++ ))
    echo "${index}. ${receipt}"
done
