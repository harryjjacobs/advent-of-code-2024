`make run_part1`

`make run_part2`

All the solutions I've seen for part 2 rely on some strong assumptions about the input, made by manually inspecting it. 
For example that there are no swapped ouput wires between different adders (i.e. wires are only swapped internally
inside each adder).

My solution also makes this assumption. It is not a general solution to the problem, but it works for the input given.

Use `make run_part2_viz` to generate a DOT graph of the circuit. For this you will need to have the Graphviz dev library
installed on your machine (`libgraphviz-dev` on Ubuntu).
