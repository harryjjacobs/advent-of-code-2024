import Foundation

struct Point {
    var x: Int64
    var y: Int64
}

struct Button {
    var x_inc: Int64
    var y_inc: Int64
}

struct Machine {
    var button_a: Button
    var button_b: Button
    var prize: Point
}

struct Counts {
    var a: Int64
    var b: Int64
}

func parseButton(line: String.SubSequence) -> Button {
    let result = line.wholeMatch(of: /Button [AB]: X(?<x>[+-][0-9]+), Y(?<y>[+-][0-9]+)/)!
    return Button.init(x_inc: Int64(result.x)!, y_inc: Int64(result.y)!)
}

func parsePrize(line: String.SubSequence) -> Point {
    let result = line.wholeMatch(of: /Prize: X=(?<x>[0-9]+), Y=(?<y>[0-9]+)/)!
    return Point.init(
        x: Int64(result.x)! + 10_000_000_000_000, y: Int64(result.y)! + 10_000_000_000_000)
}

func parseMachine(lines: String.SubSequence) -> Machine {
    let parts = lines.split(separator: "\n")
    return Machine.init(
        button_a: parseButton(line: parts[0]), button_b: parseButton(line: parts[1]),
        prize: parsePrize(line: parts[2]))
}

func parseInput() -> [Machine]? {
    let contents = try? String(contentsOf: URL(filePath: "input"), encoding: String.Encoding.utf8)
    let machineStrs = contents?.split(separator: "\n\n")

    return machineStrs?.map { lines in parseMachine(lines: lines) }
}

func almostEqual(_ a: Float80, _ b: Float80, _ epsilon: Float80 = 1e-7) -> Bool {
    return abs(a - b) <= epsilon
}

func solve(machine: Machine) -> (Int64, Int64)? {
    let k_tx = Float80(machine.prize.x)
    let k_ty = Float80(machine.prize.y)
    let k_ax = Float80(machine.button_a.x_inc)
    let k_ay = Float80(machine.button_a.y_inc)
    let k_bx = Float80(machine.button_b.x_inc)
    let k_by = Float80(machine.button_b.y_inc)

    let z_b = (k_tx - (k_ax / k_ay) * k_ty) / (k_bx - (k_ax / k_ay) * k_by)
    let z_a = (k_ty - k_by * z_b) / k_ay

    if !almostEqual(z_a.rounded(), z_a)
        || !almostEqual(z_b.rounded(), z_b)
    {
        return nil
    }

    return (Int64(z_a.rounded()), Int64(z_b.rounded()))
}

let machines = parseInput()!

var cost: Int64 = 0
for machine in machines {
    let result = solve(machine: machine)
    if result != nil {
        let (a, b) = result!
        cost += a * 3 + b
    }
}

print(cost)
