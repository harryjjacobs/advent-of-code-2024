#!/bin/bash
declare -A grid # pretend to be a 2D array by using an associative array

j=0
i=0
while IFS= read -r line; do
    for ((i=0; i < ${#line}; i++)); do
        grid[$i,$j]="${line:$i:1}"
    done
    j=$((j + 1))
done < "input"

rows=$j
cols=$i
echo "${cols}x${rows}"

sum=0

function word_search() {
    local x=$1
    local y=$2
    local dir_x=$3
    local dir_y=$4
    local word=$5
    local local_sum=$6

    if (( $x >= $cols )); then
        echo "0"
        return
    fi

    if (( $y >= $rows )); then
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

    if [ "${word:0:1}" != "${grid[$x,$y]}" ]; then
        echo "0"
        return
    fi

    if [ ${#word} == 1 ]; then
        echo "1"
        return
    fi

    x=$((x + dir_x))
    y=$((y + dir_y))

    local next=$(word_search $x $y $dir_x $dir_y "${word:1}" "$local_sum")
    echo "$((local_sum + next))"
}

# set -x  # Enable tracing

for ((j = 0; j < $rows; j++)); do
    for ((i = 0; i < $cols; i++)); do
        r=$(word_search $i $j 1 0 "XMAS" 0)
        l=$(word_search $i $j -1 0 "XMAS" 0)
        u=$(word_search $i $j 0 -1 "XMAS" 0)
        d=$(word_search $i $j 0 1 "XMAS" 0)
        ur=$(word_search $i $j 1 -1 "XMAS" 0)
        ul=$(word_search $i $j -1 -1 "XMAS" 0)
        dr=$(word_search $i $j 1 1 "XMAS" 0)
        dl=$(word_search $i $j -1 1 "XMAS" 0)
        sum=$((sum + r + l + u + d + ur + ul + dr + dl))
    done
done

echo $sum
