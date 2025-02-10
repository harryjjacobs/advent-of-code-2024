import Foundation

struct Point {
    var x: Int
    var y: Int
}

struct Button {
    var x_inc: Int
    var y_inc: Int
}

struct Machine {
    var button_a: Button
    var button_b: Button
    var prize: Point
}

struct Counts {
    var a: Int
    var b: Int
}

func parseButton(line: String.SubSequence) -> Button {
    let result = line.wholeMatch(of: /Button [AB]: X(?<x>[+-][0-9]+), Y(?<y>[+-][0-9]+)/)!
    return Button.init(x_inc: Int(result.x)!, y_inc: Int(result.y)!)
}

func parsePrize(line: String.SubSequence) -> Point {
    let result = line.wholeMatch(of: /Prize: X=(?<x>[0-9]+), Y=(?<y>[0-9]+)/)!
    return Point.init(x: Int(result.x)!, y: Int(result.y)!)
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

func almostEqual(_ a: Double, _ b: Double, _ epsilon: Double = 1e-12) -> Bool {
    return abs(a - b) <= epsilon
}

func solve(machine: Machine) -> (Int, Int)? {
    let k_tx = Double(machine.prize.x)
    let k_ty = Double(machine.prize.y)
    let k_ax = Double(machine.button_a.x_inc)
    let k_ay = Double(machine.button_a.y_inc)
    let k_bx = Double(machine.button_b.x_inc)
    let k_by = Double(machine.button_b.y_inc)

    let z_b = (k_tx - (k_ax / k_ay) * k_ty) / (k_bx - (k_ax / k_ay) * k_by)
    let z_a = (k_ty - k_by * z_b) / k_ay

    if !almostEqual(z_a.rounded(), z_a)
        || !almostEqual(z_b.rounded(), z_b)
    {
        return nil
    }

    return (Int(z_a.rounded()), Int(z_b.rounded()))
}

let machines = parseInput()!

var cost = 0
for machine in machines {
    let result = solve(machine: machine)
    if result != nil {
        let (a, b) = result!
        cost += a * 3 + b
    }
}

print(cost)
