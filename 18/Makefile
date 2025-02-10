.PHONY: all

Part1.jar: part1.kt
	kotlinc part1.kt -include-runtime -d Part1.jar

Part2.jar: part2.kt
	kotlinc part2.kt -include-runtime -d Part2.jar

run_part1: Part1.jar
	java -jar Part1.jar

run_part2: Part2.jar
	java -jar Part2.jar
