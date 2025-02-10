#include <algorithm>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <queue>
#include <ranges>
#include <sstream>
#include <string>
#include <unordered_map>
#include <unordered_set>

bool AND(bool a, bool b) { return a && b; }
bool OR(bool a, bool b) { return a || b; }
bool XOR(bool a, bool b) { return a != b; }

std::unordered_map<std::string, decltype(&AND)> gate_op_lookup = {
    {"AND", &AND},
    {"OR", &OR},
    {"XOR", &XOR},
};

typedef struct {
  std::vector<std::string> inputs;
  std::string output;
  std::string type;
} gate_t;

std::vector<gate_t> parseInput(const std::string &filename) {
  std::string line;
  std::ifstream file{filename};
  std::vector<gate_t> gates;
  while (std::getline(file, line)) {
    // std::cout << line << std::endl;
    auto delim = line.find(" -> ");
    if (delim != line.npos) {
      gate_t gate;
      auto inputs = line.substr(0, delim);
      gate.output = line.substr(delim + 4);
      std::istringstream ss{inputs};
      std::string input1;
      std::string input2;
      ss >> input1;
      ss >> gate.type;
      ss >> input2;
      gate.inputs = {input1, input2};
      gates.push_back(gate);
    }
  }
  return gates;
}

// If we make the assumption that wires are only swapped with other wires
// within the same adder, then we can inspect the gates in the adder
// (starting at the output) to determine if the adder is faulty.
void checkGate(
    const gate_t &gate,
    std::unordered_map<std::string, gate_t> output_wire_gate_lookup,
    std::unordered_map<std::string, std::vector<gate_t>> input_wire_gate_lookup,
    const std::string &final_output,
    std::unordered_set<std::string> &faulty_wires) {
  // final gate before the output
  if (gate.output.starts_with("z")) {
    // final output is the carry out from the last adder
    // (so OR is expected)
    if (gate.output == final_output) {
      if (gate.type != "OR") {
        faulty_wires.insert(gate.output);
      }
    } else if (gate.type != "XOR") {
      // all other outputs are the sum bits
      // (so XOR is expected)
      faulty_wires.insert(gate.output);
    }
  }
  if (gate.type == "XOR") {
    // XOR output should either be a z wire, or connected to an AND gate and
    // an XOR gate.
    if (!gate.output.starts_with("z")) {
      auto next_gates = input_wire_gate_lookup.find(gate.output);
      if (next_gates == input_wire_gate_lookup.end() ||
          next_gates->second.size() != 2) {
        faulty_wires.insert(gate.output);
      } else {
        auto next_gate1 = next_gates->second.at(0);
        auto next_gate2 = next_gates->second.at(1);
        auto valid = (next_gate1.type == "AND" && next_gate2.type == "XOR") ||
                     (next_gate1.type == "XOR" && next_gate2.type == "AND");
        // Only the first XOR in the adder is expected to have an AND gate
        // and an XOR gate as next gates.
        valid &= gate.inputs.at(0).starts_with("x") ||
                 gate.inputs.at(1).starts_with("x") ||
                 gate.inputs.at(0).starts_with("y") ||
                 gate.inputs.at(1).starts_with("y");
        if (!valid) {
          faulty_wires.insert(gate.output);
        }
      }
    }
  }
  if (gate.type == "AND") {
    // AND output should always be the OR gate before the carry out,
    // except for the first half-adder which outputs to the carry.
    if (gate.output.starts_with("z")) {
      faulty_wires.insert(gate.output);
    } else if (gate.inputs.at(0).ends_with("00") ||
               gate.inputs.at(1).ends_with("00")) {
      // the AND in the first half-adder is the carry, so should be
      // connected to an XOR and an AND gate
      auto next_gates = input_wire_gate_lookup.find(gate.output);
      if (next_gates == input_wire_gate_lookup.end() ||
          next_gates->second.size() != 2) {
        faulty_wires.insert(gate.output);
      } else {
        auto next_gate1 = next_gates->second.at(0);
        auto next_gate2 = next_gates->second.at(1);
        auto valid = (next_gate1.type == "AND" && next_gate2.type == "XOR") ||
                     (next_gate1.type == "XOR" && next_gate2.type == "AND");
        if (!valid) {
          faulty_wires.insert(gate.output);
        }
      }
    } else {
      auto next_gates = input_wire_gate_lookup.find(gate.output);
      if (next_gates == input_wire_gate_lookup.end() ||
          (next_gates->second.size() != 1)) {
        faulty_wires.insert(gate.output);
      } else {
        for (const auto &next_gate : next_gates->second) {
          if (next_gate.type != "OR") {
            faulty_wires.insert(gate.output);
          }
        }
      }
    }
  }
}

int main() {
  auto gates = parseInput("input");

  std::unordered_map<std::string, std::vector<gate_t>> input_wire_gate_lookup;
  std::unordered_map<std::string, gate_t> output_wire_gate_lookup;
  for (const auto &gate : gates) {
    for (const auto &input : gate.inputs) {
      if (input_wire_gate_lookup.find(input) == input_wire_gate_lookup.end()) {
        input_wire_gate_lookup.emplace(input, std::vector<gate_t>{});
      }
      input_wire_gate_lookup.at(input).push_back(gate);
    }
    output_wire_gate_lookup.emplace(gate.output, gate);
  }

  auto outputs = output_wire_gate_lookup | std::views::keys;

  int num_bits = std::ranges::count_if(
      outputs, [](const auto &output) { return output.starts_with("z"); });

  std::stringstream ss;
  ss << "z" << std::setfill('0') << std::setw(2) << num_bits - 1;
  auto final_output = ss.str();

  std::unordered_set<std::string> faulty_wires;
  for (const auto &gate : gates) {
    checkGate(gate, output_wire_gate_lookup, input_wire_gate_lookup,
              final_output, faulty_wires);
  }

  auto sorted_faulty_wires =
      std::vector<std::string>{faulty_wires.begin(), faulty_wires.end()};

  std::sort(sorted_faulty_wires.begin(), sorted_faulty_wires.end());

  for (int i = 0; i < sorted_faulty_wires.size(); i++) {
    std::cout << sorted_faulty_wires[i];
    if (i < sorted_faulty_wires.size() - 1) {
      std::cout << ",";
    }
  }
  std::cout << std::endl;

  return 0;
}
