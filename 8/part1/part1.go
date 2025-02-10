package main

import (
	"bufio"
	"log"
	"os"
	"regexp"
	"strings"
)

type Position struct {
	X int
	Y int
}

type Antenna struct {
	Character string
	Position  Position
}

type AntennaPair struct {
	Antennas [2]Antenna
}

type Grid = [][]string
type Positions []Position

var antennaRegex = regexp.MustCompile("^[A-Za-z0-9]$")

func (p1 Position) equals(p2 Position) bool {
	return p1.X == p2.X && p1.Y == p2.Y
}

func (p1 Position) add(p2 Position) Position {
	return Position{X: p1.X + p2.X, Y: p1.Y + p2.Y}
}

func (p1 Position) subtract(p2 Position) Position {
	return Position{X: p1.X - p2.X, Y: p1.Y - p2.Y}
}

func (positions Positions) contains(position Position) bool {
	for _, a := range positions {
		if a.equals(position) {
			return true
		}
	}
	return false
}

func findAntennaPairs(grid Grid) []AntennaPair {
	antennas := []Antenna{}
	for j := 0; j < len(grid); j++ {
		for i := 0; i < len(grid[0]); i++ {
			if antennaRegex.MatchString(grid[j][i]) {
				antennas = append(antennas, Antenna{Position: Position{X: i, Y: j}, Character: grid[j][i]})
			}
		}
	}
	log.Printf("Found %d antennas", len(antennas))

	// we knowingly count twice as many pairs here because it is easier to just
	// remove duplicates at the end
	antennaPairs := []AntennaPair{}
	for i := 0; i < len(antennas); i++ {
		for j := 0; j < len(antennas); j++ {
			if i == j || antennas[i].Character != antennas[j].Character {
				continue
			}
			antennaPairs = append(antennaPairs, AntennaPair{Antennas: [2]Antenna{antennas[i], antennas[j]}})
		}
	}

	return antennaPairs
}

func antinodePositions(antennaPair AntennaPair) (Position, Position) {
	diff := antennaPair.Antennas[0].Position.subtract(antennaPair.Antennas[1].Position)
	return antennaPair.Antennas[0].Position.add(diff), antennaPair.Antennas[1].Position.subtract(diff)
}

func isInGrid(grid Grid, position Position) bool {
	return position.X >= 0 && position.Y >= 0 && position.X < len(grid[0]) && position.Y < len(grid)
}

func countAntinodes(grid Grid, antennaPairs []AntennaPair) int {
	sum := 0
	seenAntinodes := Positions{}
	for _, pair := range antennaPairs {
		a, b := antinodePositions(pair)
		if isInGrid(grid, a) && !seenAntinodes.contains(a) {
			seenAntinodes = append(seenAntinodes, a)
			sum++
		}
		if isInGrid(grid, b) && !seenAntinodes.contains(b) {
			seenAntinodes = append(seenAntinodes, b)
			sum++
		}
	}
	return sum
}

func main() {
	file, err := os.Open("input")
	if err != nil {
		log.Fatal("couldn't open file")
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines) // This is the default but I'm specifying it to be explicit

	grid := Grid{}
	for ok := scanner.Scan(); ok; ok = scanner.Scan() {
		text := scanner.Text()
		if len(text) == 0 {
			break
		}
		grid = append(grid, strings.Split(text, ""))
	}

	log.Printf("Grid length: %d", len(grid))

	pairs := findAntennaPairs(grid)
	log.Printf("Found %d pairs", len(pairs))

	antinodeCount := countAntinodes(grid, pairs)
	log.Printf("Counted %d antonodes", antinodeCount)
}
