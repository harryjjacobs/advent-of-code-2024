#!/bin/bash
declare -A grid # pretend to be a 2D array by using an associative array

j=0
i=0
while IFS= read -r line; do
    for ((i=0; i < ${#line}; i++)); do
        grid[$i,$j]="${line:$i:1}"
    done
    j=$((j + 1))
done < "example"

rows=$j
cols=$i
echo "${cols}x${rows}"

sum=0

function reverse() {
    copy=$1
    len=${#copy}
    for((i=$len-1; i >= 0; i--)); do
        rev="$rev${copy:$i:1}";
    done
    echo "$rev"
}

function word_search() {
    local x=$1
    local y=$2
    local dir_x=$3
    local dir_y=$4
    local done=$5 # we've seen this much of the word
    local remaining=$6 # we have this much left to go
    local local_sum=$7
    local intersection=$8 # if we have already reached the middle of the word and are now searching for the intersecting word
    
    if (( $x >= $cols )); then
        echo "0"
        return
    fi

    if (( $x < 0 )); then
        echo "0"
        return
    fi

    if (( $y < 0 )); then
        echo "0"
        return
    fi

    if (( $y >= $rows )); then
        echo "0"
        return
    fi

    if [ "${remaining:0:1}" != "${grid[$x,$y]}" ]; then
        echo "0"
        return
    fi

    if [ ${#remaining} == 1 ]; then
        echo "1"
        return
    fi

    local word="${done}${remaining}"
    local middle="${word:$((${#word} / 2)):1}"

    if [ "$intersection" == false -a "${remaining:0:1}" == "$middle" ]; then
        # we've reached the midpoint of the word
        # we need to search for the same word intersecting
        # this one diagonally
        local left_dir_x=$((dir_x * -1))
        local left_dir_y=$dir_y
        local right_dir_x=$dir_x 
        local right_dir_y=$((dir_y * -1))

        local remaining_rev="$(reverse ${done}${remaining:0:1})"

        local left=$(word_search $((x + left_dir_x)) $((y + left_dir_y)) $left_dir_x $left_dir_y "" "${remaining:1}" 0 true)
        local left_rev=$(word_search $((x + left_dir_x)) $((y + left_dir_y)) $left_dir_x $left_dir_y "" ${remaining_rev:1} 0 true)

        local right=$(word_search $((x + right_dir_x)) $((y + right_dir_y)) $right_dir_x $right_dir_y "" "${remaining:1}" 0 true)
        local right_rev=$(word_search $((x + right_dir_x)) $((y + right_dir_y)) $right_dir_x $right_dir_y "" ${remaining_rev:1} 0 true)

        if ! [[ ("$left" == 1 && "$right_rev" == 1) || ("$right" == 1 && "$left_rev" == 1) ]]; then
            echo "0"
            return
        fi
    fi

    x=$((x + dir_x))
    y=$((y + dir_y))

    local next=$(word_search $x $y $dir_x $dir_y "${done}${remaining:0:1}" "${remaining:1}" "$local_sum" "$intersection")
    echo "$((local_sum + next))"
}



set -x  # Enable tracing

for ((j = 0; j < $rows; j++)); do
    for ((i = 0; i < $cols; i++)); do
        ur=$(word_search $i $j 1 -1 "" "MAS" 0 false)
        ul=$(word_search $i $j -1 -1 "" "MAS" 0 false)
        dr=$(word_search $i $j 1 1 "" "MAS" 0 false)
        dl=$(word_search $i $j -1 1 "" "MAS" 0 false)
        sum=$((sum + r + l + u + d + ur + ul + dr + dl))
    done
done

echo $((sum / 2)) # because each X-MAS can have two M's we end up counting all the Xs twice :)
