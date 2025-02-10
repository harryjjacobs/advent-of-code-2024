<?php    
    function readLines($file) {
        $f = fopen($file, "r");
        try {
            while ($line = fgets($f)) {
                yield $line;
            }
        } finally {
            fclose($f);
        }
    }

    function permutations(array $elements, int $length): array {
        $result = [];
    
        $permute = function(array $current, array $remaining, int $length, array &$result) use (&$permute, $elements) {
            if (count($current) === $length) {
                $result[] = $current;
                return;
            }
    
            foreach ($elements as $element) {
                $new = $current;
                $new[] = $element;
    
                $permute($new, $remaining, $length, $result);
            }
        };
    
        $permute([], $elements, $length, $result);
    
        return $result;
    }

    $operators = [
        fn($x, $y) => $x + $y,
        fn($x, $y) => $x * $y,
        fn($x, $y) => $x . $y,
    ];

    function canBeCalculated($target, $values) {
        global $operators;
        $combinations = permutations($operators, count($values));
        foreach ($combinations as $ops) {
            $result = $values[0];
            for ($i = 1; $i < count($values); $i++) {
                $result = array_values($ops)[$i - 1]($result, $values[$i]);
            }
            if ($result == $target) {
                return true;
            }
        }
        return false;
    }

    $sum=0;
    foreach (readLines("input") as $line) {
        list($target, $values_str) = explode(": ", $line);
        $values = explode(" ", $values_str);
        if (canBeCalculated($target, $values)) {
            $sum += $target;
        }
    }
    echo $sum . PHP_EOL;
