.PHONY: all
all: run_part1 run_part2

part1: part1.cc
	g++ -std=c++20 -o part1 part1.cc

part2: part2.cc
	g++ -std=c++20 -o part2 part2.cc

part2_viz: part2_viz.cc
	g++ -std=c++20 -o part2_viz part2_viz.cc `pkg-config libgvc --cflags` `pkg-config libgvc --libs`

run_part1: part1
	./part1

run_part2: part2
	./part2

run_part2_viz: part2_viz
	./part2_viz > part2.dot