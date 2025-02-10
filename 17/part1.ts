declare var require: any
var fs = require('fs');

enum Instruction {
  adv = 0,
  bxl = 1,
  bst = 2,
  jnz = 3,
  bxc = 4,
  out = 5,
  bdv = 6,
  cdv = 7,
};

interface Computer {
  A: number;
  B: number;
  C: number;
  program: number[];
  pointer: number;
  output: number[];
}

const parseInput = (): Computer => {
  const buffer = fs.readFileSync("input");
  const lines: string[] = buffer.toString().split("\n");

  return {
    A: parseInt(lines[0].split(": ")[1]),
    B: parseInt(lines[1].split(": ")[1]),
    C: parseInt(lines[2].split(": ")[1]),
    program: lines[4].split(": ")[1].split(",").map((c => parseInt(c))),
    pointer: 0,
    output: new Array(),
  };
};

const comboOperand = (computer: Computer, operand: number): number => {
  if (operand <= 3) {
    return operand;
  }
  if (operand == 4) {
    return computer.A;
  }
  if (operand == 5) {
    return computer.B;
  }
  if (operand == 6) {
    return computer.C;
  }
  throw new Error(`Invalid operand ${operand}`);
};

const performInstruction = (computer: Computer, instruction: Instruction, operand: number): boolean => {
  switch (instruction) {
    case Instruction.adv:
      computer.A = computer.A >> comboOperand(computer, operand);
      break;
    case Instruction.bdv:
      computer.B = computer.A >> comboOperand(computer, operand);
      break;
    case Instruction.cdv:
      computer.C = computer.A >> comboOperand(computer, operand);
      break;
    case Instruction.bst:
      computer.B = comboOperand(computer, operand) % 8;
      break;
    case Instruction.bxc:
      computer.B = computer.B ^ computer.C;
      break;
    case Instruction.bxl:
      computer.B = operand ^ computer.B;
      break;
    case Instruction.jnz:
      if (computer.A != 0) {
        computer.pointer = operand;
        return false;
      }
      break;
    case Instruction.out:
      computer.output.push(comboOperand(computer, operand) % 8);
      console.log("out: ", comboOperand(computer, operand) % 8);
      break;
    default:
      throw new Error(`Unknown instruction: ${instruction}`);
  }

  return true;
};

const run = (computer: Computer) => {
  while (computer.pointer < computer.program.length - 1) {
    const instruction: Instruction = computer.program[computer.pointer]
    const pointer: number = computer.program[computer.pointer + 1]
    if (performInstruction(computer, instruction, pointer)) {
      computer.pointer += 2;
    }
  }
};

const computer = parseInput();

console.log(computer)

run(computer);

console.log(computer.output.join(","))
