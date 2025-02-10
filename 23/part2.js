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

const areAllConnected = (connections, computers) => {
  for (let a of computers) {
    for (let b of computers) {
      if (a == b) {
        continue;
      }
      if (!isConnected(connections, a, b)) {
        return false;
      }
    }
  }
  return true;
}

const accumulateGroup = (connections, current, group) => {
    if (group.has(current) || !areAllConnected(connections, group.union(new Set([current])))) {
        return;
    }
    group.add(current);
    const connected = connections[current];
    for (let computer of connected) {
        accumulateGroup(connections, computer, group);
    }
};

let groups = [];
for (let computer in connections) {
    let group = new Set();
    accumulateGroup(connections, computer, group);
    groups.push(group);
}

let biggest = groups.reduce((max, x, i, arr) => x.size > max.size ? x : max, new Set());
let sorted = [...biggest].sort();
let password = sorted.join(",");
console.log(password);
