(ns part1
  (:require
   [clojure.java.io :as clojure.java.io]))

(defn parse-lines [lines]
  (mapv (fn [line] (vec (seq line))) lines))

(defn read-input [filename]
  (with-open [reader (clojure.java.io/reader filename)]
    (parse-lines (line-seq reader))))

(defn guard-dir [char]
  (case char
    \> [1, 0]
    \< [-1, 0]
    \v [0, 1]
    \^ [0, -1]))

(defn guard-char [dir]
  (case dir
    [1, 0] \>
    [-1, 0] \<
    [0, 1] \v
    [0, -1] \^))

(defn find-guard-in-row [row] ; find >, <, ^, or v
  (first (keep-indexed (fn [index char] (when (some #{char} #{\> \< \v \^}) index)) row)))

(defn grid-char [grid pos]
  (let [[x y] pos]
    (nth (nth grid y) x)))

(defn find-start [grid] ; find the guard character
  (loop [rows grid
         y 0]
    (if (empty? rows)
      nil ; we never found the character
      (let [row (first rows)
            x (find-guard-in-row row)]
        (if x
          [x y]
          (recur (rest rows) (inc y)))))))

(defn apply-dir [pos dir] ; update the position using the direction
  [(+ (nth pos 0) (nth dir 0)) (+ (nth pos 1) (nth dir 1))])

(defn out-of-bounds [grid pos dir] ; check if the next position in direction `dir` will be out of bounds
  (let [pos (apply-dir pos dir)
        [x y] pos]
    (cond
      (< x 0) true
      (>= x (count (nth grid 0))) true
      (< y 0) true
      (>= y (count grid)) true)))

(defn turn-right [dir] ; apply rotation matrix to the direction to rotate CW 90 degrees
  [(+ (* 0 (nth dir 0)) (* -1 (nth dir 1))) (+ (* 1 (nth dir 0)) (* 0 (nth dir 1)))])

(defn check-obstacle [grid pos dir]
  (let [pos (apply-dir pos dir)]
    (when (= \# (grid-char grid pos)) true)))

(defn visit [grid pos dir] ; returns the new grid and a flag to indicate if a loop was detected
  (let [char (grid-char grid pos)
        [x y] pos]
    (if (not= (guard-char dir) char)
      [(assoc grid y (assoc (nth grid y) x (guard-char dir))) false]
      [grid true])))

(defn move [grid pos dir] ; move in direction, or rotate if obstacle
  (if (check-obstacle grid pos dir)
    (let [dir (turn-right dir)]
      [grid pos dir])
    (let [pos (apply-dir pos dir)
          [grid loop] (visit grid pos dir)]
      [grid pos dir loop])))

(defn move-guard [grid pos dir] ; travel around the grid, detecting loops
  (let [grid (first (visit grid pos dir))] ; mark starting cell as visited
    (loop [grid grid
           pos pos
           dir dir]
      (if (out-of-bounds grid pos dir)
        false
        (let [[grid pos dir loop] (move grid pos dir)]
          (if loop
            true
            (recur grid pos dir)))))))

(defn all-coords [grid skip] ; all possible coordinates in the grid (i.e. [0 0], [1 0], [2 0] etc)
  (let [w (count (nth grid 0))
        h (count grid)]
    (mapcat (fn [y] (map (fn [x] [x y]) (filter #(not= [% y] skip) (range w)))) (range h))))

(defn grid-permutations [grid start] ; brute-force approach (slow). generate grids with the additional obstacle in a difference place in each
  (map (fn [[x y]] (assoc grid y (assoc (nth grid y) x \#))) (all-coords grid start)))

(defn -main []
  (let [grid (read-input "input")
        start (find-start grid)
        dir (guard-dir (grid-char grid start))
        grids (grid-permutations grid start)
        loops (count (filter true? (map #(move-guard %1 start dir) grids)))]
    (println loops)))

;; Explicitly call the -main function when running the script
(-main)
