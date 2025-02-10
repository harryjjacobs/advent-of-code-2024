import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.PriorityQueue;
import java.util.Set;
import java.util.stream.Stream;

public class Part2 {
    static Problem parseFile(String filename) throws IOException {
        Problem problem = new Problem();

        List<char[]> maze = new ArrayList<>();
        try (Stream<String> stream = Files.lines(Paths.get(filename))) {
            List<String> lines = stream.toList();
            for (int j = 0; j < lines.size(); j++) {
                int start = lines.get(j).indexOf('S');
                if (start != -1) {
                    problem.start = new Vec2(start, j);
                }
                int end = lines.get(j).indexOf('E');
                if (end != -1) {
                    problem.end = new Vec2(end, j);
                }
                maze.add(lines.get(j).toCharArray());
            }
        }

        problem.maze = maze.toArray(new char[maze.size()][]);

        return problem;
    }

    static void printMaze(char[][] maze, Vec2 position, Vec2 direction) {
        for (int j = 0; j < maze.length; j++) {
            for (int i = 0; i < maze[0].length; i++) {
                if (position.x == i && position.y == j) {
                    System.out.print(getDirectionChar(direction));
                } else {
                    System.out.print(maze[j][i]);
                }
            }
            System.out.println("");
        }
    }

    static char at(char[][] maze, Vec2 position) {
        return maze[position.y][position.x];
    }

    static boolean inBounds(char[][] maze, Vec2 position) {
        return position.x >= 0 && position.y >= 0 && position.x < maze[0].length && position.y < maze.length;
    }

    static List<RobotState> neighbours(char[][] maze, RobotState state) {
        List<RobotState> states = new ArrayList<>();
        states.add(new RobotState(state.position.Add(state.direction), state.direction));
        states.add(new RobotState(state.position, state.direction.RotatedCw()));
        states.add(new RobotState(state.position, state.direction.RotatedCcw()));
        states.removeIf(neighbour -> {
            return !inBounds(maze, neighbour.position) || maze[neighbour.position.y][neighbour.position.x] == '#';
        });
        return states;
    }

    static char getDirectionChar(Vec2 direction) {
        if (direction.x == 1 && direction.y == 0) {
            return '>';
        } else if (direction.x == -1 && direction.y == 0) {
            return '<';
        } else if (direction.x == 0 && direction.y == 1) {
            return 'v';
        } else if (direction.x == 0 && direction.y == -1) {
            return '^';
        }
        return '\0';
    }

    static int heuristic(Vec2 a, Vec2 b) {
        // manhatten distance
        return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
    }

    static int cost(RobotState a, RobotState b) {
        if (a.direction.equals(b.direction)) {
            return 1;
        } else {
            return 1000;
        }
    }

    static List<List<RobotState>> reconstructPaths(RobotState current, RobotState start, List<RobotState> currentPath,
            Map<RobotState, Set<RobotState>> routes) {
        currentPath.add(current);

        List<List<RobotState>> allPaths = new ArrayList<>();
        if (current.position.equals(start.position)) {
            allPaths.add(new ArrayList<>(currentPath));
        } else {
            for (RobotState parent : routes.getOrDefault(current, new HashSet<>())) {
                allPaths.addAll(reconstructPaths(parent, start, currentPath, routes));
            }
        }

        currentPath.remove(currentPath.size() - 1);

        return allPaths;
    }

    static List<List<RobotState>> findShortestPath(char[][] maze, RobotState startState, Vec2 end) {
        HashMap<RobotState, Integer> priorities = new HashMap<>();
        PriorityQueue<RobotState> queue = new PriorityQueue<>((a, b) -> priorities.get(a).compareTo(priorities.get(b)));

        // The currently known cost of the cheapest path from start to a given robot
        // state.
        HashMap<RobotState, Integer> costs = new HashMap<>();
        HashMap<RobotState, Set<RobotState>> routes = new HashMap<>();
        List<RobotState> endStates = new ArrayList<>();

        queue.add(startState);
        costs.put(startState, 0);

        int shortestPathCost = -1;

        while (!queue.isEmpty()) {
            RobotState state = queue.remove();
            if (state.position.equals(end)) {
                endStates.add(state);
                if (shortestPathCost == -1) {
                    shortestPathCost = costs.get(state);
                } else if (costs.get(state) > shortestPathCost) {
                    break;
                }
            }

            for (RobotState neighbour : neighbours(maze, state)) {
                int newCost = costs.get(state) + cost(state, neighbour);
                int neighbourCost = costs.getOrDefault(neighbour, Integer.MAX_VALUE);
                if (newCost <= neighbourCost) {
                    costs.put(neighbour, newCost);
                    if (newCost == neighbourCost) {
                        // We are creating a fork in the road here.
                        // This state in the paths map will have two options.
                        routes.get(neighbour).add(state);
                    } else {
                        routes.put(neighbour, new HashSet<>(List.of(state)));
                    }
                    int priority = newCost + heuristic(neighbour.position, end);
                    priorities.put(neighbour, priority);
                    queue.add(neighbour);
                }
            }
        }

        return endStates.stream()
                .flatMap(endState -> reconstructPaths(endState, startState, new ArrayList<>(), routes).stream())
                .toList();
    }

    public static void main(String[] args) throws IOException {
        Problem problem = parseFile("input");

        List<List<RobotState>> paths = findShortestPath(problem.maze, new RobotState(problem.start, new Vec2(1, 0)),
                problem.end);

        HashSet<Vec2> coveredTiles = new HashSet<>();
        for (List<RobotState> path : paths) {
            coveredTiles.addAll(path.stream().map(p -> p.position).toList());
        }

        System.err.println(coveredTiles.size());
    }
}

class Vec2 {
    public int x;
    public int y;

    public Vec2() {
        x = 0;
        y = 0;
    }

    public Vec2(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public Vec2 Add(Vec2 other) {
        return new Vec2(x + other.x, y + other.y);
    }

    public Vec2 RotatedCcw() {
        return new Vec2(x * 0 - y, x);
    }

    public Vec2 RotatedCw() {
        return new Vec2(x * 0 + y, x * -1);
    }

    @Override
    public String toString() {
        return "(" + x + ", " + y + ")";
    }

    @Override
    public final boolean equals(Object o) {
        if (o == null || !(o instanceof Vec2)) {
            return false;
        }

        Vec2 other = (Vec2) o;
        return x == other.x && y == other.y;
    }

    @Override
    public final int hashCode() {
        return Objects.hash(x, y);
    }
}

class Problem {
    public char[][] maze;
    public Vec2 start;
    public Vec2 end;
}

class RobotState {
    public Vec2 position;
    public Vec2 direction;

    public RobotState(Vec2 position, Vec2 direction) {
        this.position = position;
        this.direction = direction;
    }

    @Override
    public final boolean equals(Object o) {
        if (o == null || !(o instanceof RobotState)) {
            return false;
        }

        RobotState other = (RobotState) o;

        return position.equals(other.position) && direction.equals(other.direction);
    }

    @Override
    public final int hashCode() {
        return Objects.hash(position.hashCode(), direction.hashCode());
    }
}

class Move {
    public RobotState state;
    public Integer cost;

    Move(RobotState state, Integer cost) {
        this.state = state;
        this.cost = cost;
    }
}
