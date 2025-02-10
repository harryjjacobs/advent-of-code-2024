#include <graphviz/gvc.h>

#include <fstream>
#include <iomanip>
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
  std::vector<std::string> inputs;
  std::string output;
  std::string type;
} gate_t;

std::vector<gate_t> parseInput(const std::string &filename) {
  std::string line;
  std::ifstream file{filename};
  std::vector<gate_t> gates;
  while (std::getline(file, line)) {
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
void createGraph(std::vector<gate_t> gates) {
  char rankdir_str[] = "rankdir";
  char lr_str[] = "LR";
  char shape_str[] = "shape";
  char ellipse_str[] = "ellipse";
  char box_str[] = "box";
  char label_str[] = "label";
  char pos_str[] = "pos";
  char pin_str[] = "pin";
  char true_str[] = "true";
  char empty_str[] = "";

  GVC_t *gvc = gvContext();
  Agraph_t *g = agopen(const_cast<char *>("G"), Agdirected, nullptr);
  agsafeset(g, rankdir_str, lr_str, empty_str);

  FILE *fp;
  if ((fp = fopen("part2.dot", "w")) == nullptr) {
    std::cerr << "Error opening file" << std::endl;
    return;
  }

  std::unordered_map<std::string, Agnode_t *> signal_nodes;
  uint32_t gate_count = 0;
  for (const auto &gate : gates) {
    for (const auto &inp : gate.inputs) {
      if (signal_nodes.find(inp) == signal_nodes.end()) {
        Agnode_t *node = agnode(g, const_cast<char *>(inp.c_str()), 1);
        agsafeset(node, shape_str, ellipse_str, empty_str);
        signal_nodes[inp] = node;
      }
    }

    if (signal_nodes.find(gate.output) == signal_nodes.end()) {
      Agnode_t *node = agnode(g, const_cast<char *>(gate.output.c_str()), 1);
      agsafeset(node, shape_str, ellipse_str, empty_str);
      signal_nodes[gate.output] = node;
    }

    std::stringstream gate_id;
    gate_id << "gate_" << gate_count++;
    Agnode_t *gate_node =
        agnode(g, const_cast<char *>(gate_id.str().c_str()), 1);
    agsafeset(gate_node, shape_str, box_str, empty_str);
    agsafeset(gate_node, label_str, const_cast<char *>(gate.type.c_str()),
              empty_str);

    for (const auto &inp : gate.inputs) {
      agedge(g, signal_nodes[inp], gate_node, nullptr, 1);
    }
    agedge(g, gate_node, signal_nodes[gate.output], nullptr, 1);
  }

  gvLayout(gvc, g, "dot");
  gvRender(gvc, g, "dot", fp);
  gvFreeLayout(gvc, g);
  agclose(g);
  fclose(fp);
  gvFreeContext(gvc);
}

// std::vector<int> findFaultyAdders(int adders) {
//   std::vector<int> faulty_adders;
//   for (int i = 1; i <= adders; i++) {
//     // x00, x01, x02...x11, x12, x13
//     std::stringstream ss;
//     ss << std::setw(2) << std::setfill('0') << i;
//     auto x = "x" + ss.str();
//     auto y = "y" + ss.str();
//     auto z = "z" + ss.str();

//   }
//   return faulty_adders;
// }

int main() {
  auto gates = parseInput("input");

  createGraph(gates);

  return 0;
}
