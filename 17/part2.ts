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
  A: bigint;
  B: bigint;
  C: bigint;
  program: number[];
  pointer: number;
  output: number[];
}

const parseInput = (): Computer => {
  const buffer = fs.readFileSync("input");
  const lines: string[] = buffer.toString().split("\n");

  return {
    A: BigInt(parseInt(lines[0].split(": ")[1])),
    B: BigInt(parseInt(lines[1].split(": ")[1])),
    C: BigInt(parseInt(lines[2].split(": ")[1])),
    program: lines[4].split(": ")[1].split(",").map((c => parseInt(c))),
    pointer: 0,
    output: new Array(),
  };
};

const comboOperand = (computer: Computer, operand: number): bigint => {
  if (operand <= 3) {
    return BigInt(operand);
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
      computer.B = comboOperand(computer, operand) % 8n;
      break;
    case Instruction.bxc:
      computer.B = computer.B ^ computer.C;
      break;
    case Instruction.bxl:
      computer.B = BigInt(operand) ^ computer.B;
      break;
    case Instruction.jnz:
      if (computer.A != 0n) {
        computer.pointer = operand;
        return false;
      }
      break;
    case Instruction.out:
      computer.output.push(Number(comboOperand(computer, operand) % 8n));
      break;
    default:
      throw new Error(`Unknown instruction: ${instruction}`);
  }

  return true;
};

const computer = parseInput();
const program = computer.program;

const run = (computer: Computer) => {
  while (computer.pointer < computer.program.length - 1) {
    const instruction: Instruction = computer.program[computer.pointer]
    const pointer: number = computer.program[computer.pointer + 1]
    if (performInstruction(computer, instruction, pointer)) {
      computer.pointer += 2;
    }
  }
};

const arraysEqual = (program1: number[], program2: number[]): boolean => {
  return program1.length === program2.length && program1.every((value, index) => value === program2[index]);
}

const check = (a: bigint, index: number): BigInt | null => {
  let desiredOutput = program.slice(index);
  let computer: Computer = {
    A: a,
    B: 0n,
    C: 0n,
    program: program,
    pointer: 0,
    output: [],
  };
  run(computer);
  if (arraysEqual(computer.output, desiredOutput)) {
    if (index == 0) {
      return a;
    }
    for (var j = 0; j < 8; j++) {
      const result = check((a << 3n) + BigInt(j), index - 1);
      if (result) {
        return result;
      }
    }
  }
  return null;
}

let result;
for (var j = 0; j < 8; j++) {
  result = check(BigInt(j), program.length - 1);
  if (result) {
    break;
  }
}

console.log(Number(result));
