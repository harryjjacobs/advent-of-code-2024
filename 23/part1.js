var fs = require('fs');

const parseInput = () => {
  const buffer = fs.readFileSync("input");
  const lines = buffer.toString().trim().split("\n");
  return lines;
};

const parseConnections = (lines) => {
  const connections = {};
  lines.forEach((line) => {
    const [from, to] = line.split("-");
    if (!connections[from]) {
      connections[from] = new Set();
    }
    connections[from].add(to);
    if (!connections[to]) {
      connections[to] = new Set();
    }
    connections[to].add(from);
  });
  return connections;
}

const connections = parseConnections(parseInput());

const isConnected = (connections, a, b) => {
  if (a in connections) {
    if (connections[a].has(b)) {
      return true;
    }
  }
  if (b in connections) {
    if (connections[b].has(a)) {
      return true;
    }
  }
  return false;
}

const getGroupsOf3 = (connections, computer) => {
  const connected = connections[computer];
  let groups = [];
  for (let a of connected) {
    for (let b of connected) {
      if (a == b) {
        continue;
      }
      if (isConnected(connections, a, b)) {
        groups.push(new Set([a, b, computer]));
      }
    }
  }
  return groups;
}

const areSetsEqual = (xs, ys) => xs.size === ys.size && [...xs].every((x) => ys.has(x));

const anyComputerStartsWithT = (s) => [...s].find(c => c.startsWith("t"));

let sets = [];
for (let computer in connections) {
  for (let group of getGroupsOf3(connections, computer)) {
    if (group.size !== 3){
      continue;
    } 
    if (sets.find(set => areSetsEqual(set, group))) {
      continue;
    }
    if (anyComputerStartsWithT(group)) {
      sets.push(group);
    }
  }
}

console.log(sets.length);
