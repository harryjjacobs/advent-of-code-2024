#include <fstream>
#include <iostream>
#include <queue>
#include <ranges>
#include <sstream>
#include <string>
#include <unordered_map>

bool AND(bool a, bool b) { return a && b; }
bool OR(bool a, bool b) { return a || b; }
bool XOR(bool a, bool b) { return a != b; }

std::unordered_map<std::string, decltype(&AND)> gate_op_lookup = {
    {"AND", &AND},
    {"OR", &OR},
    {"XOR", &XOR},
};

typedef struct {
  std::string input1;
  std::string input2;
  std::string output;
  std::string type;
} gate_t;

std::vector<gate_t> parseInput(
    const std::string &filename,
    std::unordered_map<std::string, bool> &initial_values) {
  std::string line;
  std::ifstream file{filename};
  std::vector<gate_t> gates;
  while (std::getline(file, line)) {
    // std::cout << line << std::endl;
    auto delim = line.find(": ");
    if (delim != line.npos) {
      auto wire = line.substr(0, delim);
      auto value = atoi(line.substr(delim + 2).c_str());
      initial_values.emplace(wire, value);
    } else if (!line.empty()) {
      gate_t gate;
      auto delim = line.find(" -> ");
      auto inputs = line.substr(0, delim);
      gate.output = line.substr(delim + 4);
      std::istringstream ss{inputs};
      ss >> gate.input1;
      ss >> gate.type;
      ss >> gate.input2;
      gates.push_back(gate);
    }
  }
  return gates;
}

std::unordered_map<std::string, bool> findOutputs(
    std::vector<gate_t> gates,
    const std::unordered_map<std::string, bool> &initial_values) {
  std::deque<gate_t> remaining_outputs{gates.begin(), gates.end()};
  std::unordered_map<std::string, bool> known_wires = initial_values;

  while (!remaining_outputs.empty()) {
    auto gate = remaining_outputs.front();
    remaining_outputs.pop_front();
    auto input1 = known_wires.find(gate.input1);
    auto input2 = known_wires.find(gate.input2);
    if (input1 == known_wires.end() || input2 == known_wires.end()) {
      remaining_outputs.push_back(gate);
      continue;
    }
    auto value = gate_op_lookup[gate.type](input1->second, input2->second);
    known_wires.emplace(gate.output, value);
  }

  return known_wires;
}

void filterNonZ(std::unordered_map<std::string, bool> &outputs) {
  std::erase_if(outputs, [](auto &kv) { return kv.first.substr(0, 1) != "z"; });
}

int main() {
  std::unordered_map<std::string, bool> initial_values;
  auto gates = parseInput("input", initial_values);

  auto outputs = findOutputs(gates, initial_values);
  filterNonZ(outputs);

  auto keys = std::views::keys(outputs);
  std::vector<std::string> sorted_keys{keys.begin(), keys.end()};
  std::sort(sorted_keys.begin(), sorted_keys.end());

  long int value = 0;
  for (int i = sorted_keys.size() - 1; i >= 0; i--) {
    value += ((long int)(outputs[sorted_keys[i]]) << i);
  }

  std::cout << value << std::endl;

  return 0;
}
