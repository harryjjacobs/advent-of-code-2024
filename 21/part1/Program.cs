using Path = System.Collections.Generic.IEnumerable<Point>;

var numericKeys = new Dictionary<char, Point>
{
    {'0', new Point(1, 3)},
    {'1', new Point(0, 2)},
    {'2', new Point(1, 2)},
    {'3', new Point(2, 2)},
    {'4', new Point(0, 1)},
    {'5', new Point(1, 1)},
    {'6', new Point(2, 1)},
    {'7', new Point(0, 0)},
    {'8', new Point(1, 0)},
    {'9', new Point(2, 0)},
    {'A', new Point(2, 3)},
};

var directionalKeys = new Dictionary<char, Point>
{
    {'^', new Point(1, 0)},
    {'v', new Point(1, 1)},
    {'<', new Point(0, 1)},
    {'>', new Point(2, 1)},
    {'A', new Point(2, 0)},
};

var numericKeypadPathLookup = GenerateAllPaths(numericKeys);
var directionalKeypadPathLookup = GenerateAllPaths(directionalKeys);

int result = 0;
var lines = File.ReadLines("input");
foreach (var line in lines)
{
    int cost = 0;
    char prevKey = 'A'; // on numeric keypad
    foreach (var key in line)
    {
        var move = new Move(numericKeys[prevKey], numericKeys[key]);
        var paths = numericKeypadPathLookup[move];
        var path = paths.Select(PathToDirections).Select(directions => FindShortestPath(directions, 2)).MinBy((r) => r.Count());
        // PrintDirections(path!);
        cost += path!.Count();
        prevKey = key;
    }
    result += cost * int.Parse(line[..^1]); // https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/operators/member-access-operators#range-operator-
}

Console.WriteLine(result);

IEnumerable<char> FindShortestPath(IEnumerable<char> directions, int endLevel, int level = 0)
{
    if (level == endLevel)
    {
        return directions;
    }

    char prevKey = 'A';
    var cost = 0;
    var path = new List<char>();
    foreach (var key in directions)
    {
        var move = new Move(directionalKeys[prevKey], directionalKeys[key]);
        IEnumerable<IEnumerable<char>> newDirections;
        if (move.start == move.end)
        {
            newDirections = [['A']];
        }
        else
        {
            var paths = directionalKeypadPathLookup[move];
            newDirections = paths.Select(PathToDirections);
        }
        var result = newDirections.Select(directions => FindShortestPath(directions, endLevel, level + 1)).MinBy((r) => r.Count());
        cost += result!.Count();
        path.AddRange(result!);
        prevKey = key;
    }

    return path;
}

IEnumerable<Path> GeneratePaths(Move move, Dictionary<char, Point> keys)
{
    var dx = move.end.x - move.start.x;
    var dy = move.end.y - move.start.y;

    var relativePath = new List<Point>();
    for (int i = 0; i < Math.Abs(dx); i++)
    {
        relativePath.Add(new Point(Math.Abs(dx) / dx, 0));
    }
    for (int i = 0; i < Math.Abs(dy); i++)
    {
        relativePath.Add(new Point(0, Math.Abs(dy) / dy));
    }

    return relativePath
        .GetPermutations()
        .Distinct(new SequenceEqualityComparer<Point>())
        .Select(relPath =>
        {
            var path = new List<Point>();
            var point = move.start;
            path.Add(point);
            foreach (var relPoint in relPath)
            {
                point = point.Add(relPoint);
                path.Add(point);
            }
            return path;
        })
        .Where(path => path.All(point => keys.ContainsValue(point)));
}

Dictionary<Move, IEnumerable<Path>> GenerateAllPaths(Dictionary<char, Point> keys)
{
    var paths = new Dictionary<Move, IEnumerable<Path>>();
    foreach (var key1 in keys.Values)
    {
        foreach (var key2 in keys.Values)
        {
            if (key1 == key2)
            {
                continue;
            }
            var move = new Move(key1, key2);
            paths.Add(move, GeneratePaths(move, keys));
        }
    }
    return paths;
}

IEnumerable<char> PathToDirections(Path path)
{
    var points = path.ToList();
    var previous = path.First();
    foreach (var point in path.Skip(1))
    {
        yield return DirectionToKey(previous, point);
        previous = point;
    }
    yield return 'A';
}

char DirectionToKey(Point prev, Point current)
{
    if (current.x > prev.x)
    {
        return '>';
    }
    else if (current.x < prev.x)
    {
        return '<';
    }
    else if (current.y > prev.y)
    {
        return 'v';
    }
    else if (current.y < prev.y)
    {
        return '^';
    }
    throw new Exception("Couldn't work out direction - points are the same!");
}

void PrintDirections(IEnumerable<char> directions)
{
    Console.WriteLine(String.Join("", directions));
}

class SequenceEqualityComparer<T> : IEqualityComparer<IEnumerable<T>>
{
    public bool Equals(IEnumerable<T>? a, IEnumerable<T>? b)
    {
        if (a == null) return b == null;
        if (b == null) return false;

        var result = a.SequenceEqual(b);

        return result;
    }

    public int GetHashCode(IEnumerable<T> val)
    {
        return val.Where(e => e != null).Select(e => e!.GetHashCode() & 0x7FFFFFFF).Aggregate(0, (a, b) => a ^ b);
    }
}

class Point : IEquatable<Point>
{
    public Point(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public int x;
    public int y;

    public Point Add(Point point)
    {
        return new Point(this.x + point.x, this.y + point.y);
    }

    public Point Subtract(Point point)
    {
        return new Point(this.x - point.x, this.y - point.y);
    }

    public override string ToString()
    {
        return $"({this.x}, {this.y})";
    }

    public bool Equals(Point? other)
    {
        if (other == null)
        {
            return false;
        }
        return this.x.Equals(other.x) && this.y.Equals(other.y);
    }

    public override bool Equals(object? obj) => this.Equals(obj as Point);
    public override int GetHashCode() => (this.x, ",", this.y).GetHashCode();
}

class Move : IEquatable<Move>
{
    public Move(Point start, Point end)
    {
        this.start = start;
        this.end = end;
    }

    public override string ToString()
    {
        return $"{this.start} -> {this.end}";
    }

    public bool Equals(Move? other)
    {
        if (other == null)
        {
            return false;
        }
        return this.start.Equals(other.start) && this.end.Equals(other.end);

    }

    public override bool Equals(object? obj) => this.Equals(obj as Point);
    public override int GetHashCode() => HashCode.Combine(this.start, this.end);

    public Point start;
    public Point end;
}

static class Extensions
{
    public static IEnumerable<int> To(this int from, int to)
    {
        if (from < to)
        {
            while (from <= to)
            {
                yield return from++;
            }
        }
        else
        {
            while (from >= to)
            {
                yield return from--;
            }
        }
    }

    // I stole this permutations code from https://stackoverflow.com/a/32544916.
    // I could have implemented something myself but it felt like a waste of time.

    public static IEnumerable<IEnumerable<T>> GetPermutations<T>(this IEnumerable<T> enumerable)
    {
        var array = enumerable as T[] ?? enumerable.ToArray();

        var factorials = Enumerable.Range(0, array.Length + 1)
            .Select(Factorial)
            .ToArray();

        for (var i = 0L; i < factorials[array.Length]; i++)
        {
            var sequence = GenerateSequence(i, array.Length - 1, factorials);

            yield return GeneratePermutation(array, sequence);
        }
    }

    private static IEnumerable<T> GeneratePermutation<T>(T[] array, IReadOnlyList<int> sequence)
    {
        var clone = (T[])array.Clone();

        for (int i = 0; i < clone.Length - 1; i++)
        {
            Swap(ref clone[i], ref clone[i + sequence[i]]);
        }

        return clone;
    }

    private static int[] GenerateSequence(long number, int size, IReadOnlyList<long> factorials)
    {
        var sequence = new int[size];

        for (var j = 0; j < sequence.Length; j++)
        {
            var facto = factorials[sequence.Length - j];

            sequence[j] = (int)(number / facto);
            number = (int)(number % facto);
        }

        return sequence;
    }

    static void Swap<T>(ref T a, ref T b)
    {
        T temp = a;
        a = b;
        b = temp;
    }

    private static long Factorial(int n)
    {
        long result = n;

        for (int i = 1; i < n; i++)
        {
            result = result * i;
        }

        return result;
    }
}
