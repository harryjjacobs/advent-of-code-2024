class Part1 {
    static Character[][] parse(String fileName) {
        def list = new File(fileName).text.readLines()
        return list.collect { it.toCharArray() }
    }

    static Tuple2<Point, Point> findStartEnd(Character[][] grid) {
        Point start;
        Point end;
        for (int j = 0; j < grid.length; j++) {
            for (int i = 0; i < grid[0].length; i++) {
                if (grid[j][i] == 'S') {
                    start = new Point(x: i, y: j);
                } else if (grid[j][i] == 'E') {
                    end = new Point(x: i, y: j);
                }
            }
        }
        return new Tuple2(start, end)
    }

    static boolean inBounds(Character[][] grid, Point point) {
        return point.x >= 0 && point.y >= 0 && point.x < grid[0].length && point.y < grid.length;
    }

    static Point[] moves(Character[][] grid, Point point) {
        def points = [
            new Point(x: point.x + 1, y: point.y),
            new Point(x: point.x - 1, y: point.y),
            new Point(x: point.x, y: point.y + 1),
            new Point(x: point.x, y: point.y - 1)
        ]
        return points.findAll { p -> inBounds(grid, p) && grid[p.y][p.x] != '#' }
    }

    static Point[] cheatMoves(Character[][] grid, Point point, int length) {
        def points = []
        for (int y = -length; y <= length; y++) {
            for (int x = -length; x <= length; x++) {
                if (x == 0 && y == 0) {
                    continue
                }
                if (Math.abs(x) + Math.abs(y) <= length) {
                    points.add(new Point(x: point.x + x, y: point.y + y))
                }
            }
        }

        return points.findAll { inBounds(grid, it) && grid[it.y][it.x] != '#' }
    }

    static int heuristic(Point a, Point b) {
        return Math.abs(a.x - b.x) + Math.abs(a.y - b.y)
    }

    static int cost(Point a, Point b) {
        return heuristic(a, b)
    }

    static Point[] reconstructPath(Map<Point, Point> route, Point end) {
        def path = []
        def current = end
        while (current) {
            path.add(current)
            current = route[current]
        }
        return path.reverse()
    }

    static Tuple2<Point[], Map<Point, Integer>> findShortestPath(Character[][] grid, Point start, Point end) {
        def priorities = [:]
        def queue = new PriorityQueue<Point>({ a, b -> priorities[a].compareTo(priorities[b]) })
        def costs = [:]
        def route = [:]

        queue.add(start)
        costs[start] = 0

        while (!queue.isEmpty()) {
            def current = queue.remove()

            if (current == end) {
                return new Tuple2(reconstructPath(route, current), costs)
            }

            moves(grid, current).each { move ->
                def currentCost = costs[current]
                def newCost = currentCost + cost(current, move)
                if (newCost < costs.getOrDefault(move, Integer.MAX_VALUE)) {
                    costs[move] = newCost
                    def priority = newCost + heuristic(move, end)
                    priorities[move] = priority
                    route[move] = current
                    queue.add(move)
                }
            }
        }

        return -1
    }

    static void main(String... args) {
        def grid = parse('input');
        def (Point start, Point end) = findStartEnd(grid)

        def (path, costs) = findShortestPath(grid, start, end)

        def lengthDiff = []

        path.each { point -> 
            cheatMoves(grid, point, 20).each { move ->
                def cheatLength = Math.abs(move.x - point.x) + Math.abs(move.y - point.y)
                lengthDiff.add(costs[move] - costs[point] - cheatLength)
            }
        }

        lengthDiff = lengthDiff.findAll { it > 0 && it >= 100 }
        // println(lengthDiff.sort())
        println(lengthDiff.size())
    }
}

import groovy.transform.EqualsAndHashCode
@EqualsAndHashCode
class Point {
    int x
    int y

    @Override
    String toString() {
        return "(${x}, ${y})"
    }
}

import groovy.transform.EqualsAndHashCode
@EqualsAndHashCode
class State {
    Point position
    int cheats
}
