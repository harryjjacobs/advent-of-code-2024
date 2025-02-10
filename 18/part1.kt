import java.io.File
import java.io.BufferedReader
import java.util.Objects
import java.util.PriorityQueue

import kotlin.math.abs

data class Point(val x: Int, val y: Int) {
    companion object {
        operator fun invoke(line: String): Point {
            val split = line.split(",")
            return Point(split[0].toInt(), split[1].toInt())
        }
    }

    override fun toString(): String = "($x, $y)"

    override fun equals(other: Any?)
        = (other is Point)
        && x == other.x
        && y == other.y

    override fun hashCode() = Objects.hash(x, y)
}

enum class Cell {
    SAFE,
    CORRUPTED,
}

fun parseInput(size: Point): Array<Array<Cell>> {
    val lineList = mutableListOf<Point>()
    File("input").useLines { lines -> lineList.addAll(lines.take(1024).map { line -> Point(line) }) }

    val array = Array(size.y) { Array(size.x) { Cell.SAFE } }
    lineList.forEach { array[it.y][it.x] = Cell.CORRUPTED }

    return array;
}

fun inBounds(grid: Array<Array<Cell>>, point: Point): Boolean {
    return point.x >= 0 && point.y >= 0 && point.x < grid[0].size && point.y < grid.size;
}

fun moves(grid: Array<Array<Cell>>, point: Point): Array<Point> {
    var points = arrayOf(
        Point(point.x + 1, point.y),
        Point(point.x - 1, point.y),
        Point(point.x, point.y + 1),
        Point(point.x, point.y - 1),
    )
    return points.filter { inBounds(grid, it) && grid[it.y][it.x] != Cell.CORRUPTED }.toTypedArray()
}

fun heuristic(a: Point, b: Point): Int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}

fun cost(a: Point, b: Point): Int {
    return heuristic(a, b)
}

fun findShortestPath(grid: Array<Array<Cell>>, start: Point, end: Point): Int {
    val priorities = mutableMapOf<Point, Int>()
    val queue = PriorityQueue<Point> { a, b -> priorities[a]!!.compareTo(priorities[b]!!) }
    val costs = mutableMapOf<Point, Int>()

    queue.add(start)
    costs[start] = 0

    while (queue.isNotEmpty()) {
        val state = queue.remove()

        if (state == end) {
            return costs[state]!!
        }

        for (move in moves(grid, state)) {
            val currentCost = costs[state]!!
            val newCost = currentCost + cost(state, move)
            if (newCost < costs.getOrDefault(move, Int.MAX_VALUE)) {
                costs[move] = newCost
                val priority = newCost + heuristic(move, end)
                priorities[move] = priority
                queue.add(move)
            }
        }
    }

    return -1
}

fun main(args: Array<String>) {
    val size = Point(71, 71)
    val start = Point(0, 0)
    val end = Point(size.x - 1, size.y - 1)
    val grid = parseInput(size)

    val pathLength = findShortestPath(grid, start, end)
    print(pathLength)
}
