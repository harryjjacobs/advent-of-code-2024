.PHONY: all
all: run_part1 run_part2

run_part1: part1.erl
	erlc part1.erl && erl -noshell -s part1 main -eval 'init:stop()'

run_part2: part2.erl
	erlc part2.erl && erl -noshell -s part2 main -eval 'init:stop()'
