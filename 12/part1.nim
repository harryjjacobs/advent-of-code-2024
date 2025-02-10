import strutils
import std/lists
import std/tables
import std/sequtils

type
    Point = tuple[x: int, y: int]
    # Plot = ref object   
    Plot = tuple[symbol: char, neighbours: int, visited: bool]
    # Grid = Table[Point, Plot]
    Grid = seq[seq[ref Plot]]
    Region = seq[ref Plot]

var grid: Grid = newSeq[seq[ref Plot]]()

let contents = readFile("input").strip()
let lines = contents.splitLines()
let h = lines.len
let w = lines[0].len

for j, line in lines:
    grid.add(newSeq[ref Plot]())
    for i, symbol in line:
        var plot = Plot.new()
        plot.neighbours = 0
        plot.symbol = symbol
        plot.visited = false
        grid[j].add(plot)


proc neighbour_points(point: Point): seq[Point] =
    let points = @[
        (point.x + 1, point.y), 
        (point.x - 1, point.y),
        (point.x, point.y + 1),
        (point.x, point.y - 1)
    ]
    return filter(points, proc(p: Point): bool = p.y >= 0 and p.x >= 0 and p.y < w and p.x < h)

proc neighbours(symbol: char, point: Point): seq[Point] =
    let points = neighbour_points(point)
    var neighbours = newSeq[Point]()
    for point in points:
        let plot = grid[point.y][point.x]
        if plot.symbol == symbol and not plot.visited:
            neighbours.add(point)
    return neighbours

proc find_region(symbol: char, point: Point): Region =
    var plot = grid[point.y][point.x]
    
    if plot.visited:
        return @[]

    plot.visited = true

    var plots  = newSeq[ref Plot]()
    plots.add(plot)

    plot.neighbours = 0
    for neighbour_point in neighbour_points(point):
        let neighbour_plot = grid[neighbour_point.y][neighbour_point.x]
        if neighbour_plot.symbol != symbol:
            continue
        if not neighbour_plot.visited:
            let region = find_region(symbol, neighbour_point)
            for neighbour_plot in region:
                plots.add(neighbour_plot)
        plot.neighbours += 1

    return plots

var regions = newSeq[Region]()

for j in 0..h-1:
    for i in 0..w-1:
        let plot = grid[j][i]
        let symbol = plot.symbol
        let region = find_region(symbol, (i, j))
        if region.len > 0:
            regions.add(region)

var total = 0
for region in regions:
    var area = region.len
    var perimeter = 0
    for plot in region:
        # echo("neighbours ", plot.neighbours)
        perimeter += 4 - plot.neighbours
    total += area * perimeter

echo total