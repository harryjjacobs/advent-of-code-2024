(ns part1
  (:require
   [clojure.java.io :as clojure.java.io]))

(defn parse-lines [lines]
  (mapv (fn [line] (vec (seq line))) lines))

(defn read-input [filename]
  (with-open [reader (clojure.java.io/reader filename)]
    (parse-lines (line-seq reader))))

(defn guard-direction [char]
  (case char
    \> [1, 0]
    \< [-1 0]
    \v [0, 1]
    \^ [0, -1]))

(defn find-guard-in-row [row]
  (first (keep-indexed (fn [index char] (when (some #{char} #{\> \< \v \^}) index)) row)))

(defn map-char [map pos]
  (let [[x y] pos]
    (nth (nth map y) x)))

(defn find-start [map]
  (loop [rows map
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

(defn out-of-bounds [map pos dir]
  (let [pos (apply-dir pos dir)
        [x y] pos]
    (cond
      (< x 0) true
      (>= x (count (nth map 0))) true
      (< y 0) true
      (>= y (count map)) true)))

(defn turn-right [dir] ; apply rotation matrix to the direction to rotate CW 90 degrees
  [(+ (* 0 (nth dir 0)) (* -1 (nth dir 1))) (+ (* 1 (nth dir 0)) (* 0 (nth dir 1)))])

(defn check-obstacle [map pos dir]
  (let [pos (apply-dir pos dir)]
    (when (= \# (map-char map pos)) true)))

(defn visit [map pos] ; returns the new map and a flag to indicate if a new cell was visited
  (let [char (map-char map pos)
        [x y] pos]
    (if (not= char \X)
      [(assoc map y (assoc (nth map y) x \X)) true]
      [map false])))

(defn move [map pos dir count]
  (if (check-obstacle map pos dir)
    (let [dir (turn-right dir)]
      [map pos dir count])
    (let [pos (apply-dir pos dir)
          [map new] (visit map pos)]
      [map pos dir (if new (inc count) count)])))

(defn move-guard [map pos dir]
  (let [map (first (visit map pos))] ; mark starting cell as visited
    (loop [map map
           pos pos
           dir dir
           count 1]
      (if (out-of-bounds map pos dir)
        count
        (let [[map pos dir count] (move map pos dir count)]
            ;; (println pos)
            ;; (println count)
          (recur map pos dir count))))))


(defn -main []
  (let [map (read-input "input")
        start (find-start map)
        dir (guard-direction (map-char map start))
        end (move-guard map start dir)]
    (println end)))

;; Explicitly call the -main function when running the script
(-main)
