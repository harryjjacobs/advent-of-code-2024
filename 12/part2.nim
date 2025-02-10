import strutils
import std/sequtils

type
    Point = tuple[x: int, y: int]
    Plot = tuple[symbol: char, neighbours: int, visited: bool, position: Point]
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
        plot.position = (i, j)
        plot.neighbours = 0
        plot.symbol = symbol
        plot.visited = false
        grid[j].add(plot)

proc all_neighbour_points(point: Point): seq[Point] = 
    return @[
        (point.x + 1, point.y), 
        (point.x - 1, point.y),
        (point.x, point.y + 1),
        (point.x, point.y - 1)
    ]

proc in_bounds(p: Point): bool =
    return p.y >= 0 and p.x >= 0 and p.y < w and p.x < h

proc neighbour_points(point: Point): seq[Point] =
    let points = all_neighbour_points(point)
    return filter(points, in_bounds)

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

proc count_corners(region: Region): int =
    var count = 0
    for plot in region:
        let corner_dirs: seq[Point] = @[
            (1, 1), 
            (1, -1),
            (-1, 1),
            (-1, -1)
        ]
        for dir in corner_dirs:
            let point: Point = (plot.position.x + dir.x, plot.position.y + dir.y)
            let corner_in_region = in_bounds(point) and grid[point.y][point.x].symbol == region[0].symbol
            let left: Point = (point.x + -1 * dir.x, point.y)
            let right: Point = (point.x, point.y + -1 * dir.y)
            var left_in_region = in_bounds(left) and grid[left.y][left.x].symbol == region[0].symbol
            var right_in_region = in_bounds(right) and grid[right.y][right.x].symbol == region[0].symbol
            if (left_in_region and right_in_region and not corner_in_region) or (not left_in_region and not right_in_region):
                count += 1

    return count

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
    let area = region.len
    let side_count = count_corners(region)
    total += area * side_count

echo total