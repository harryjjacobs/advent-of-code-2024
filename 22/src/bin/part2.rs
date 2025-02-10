use std::{
    collections::HashMap,
    fs::File,
    hash::Hash,
    io::{BufRead, BufReader},
    iter,
};

fn mix(secret: i64, value: i64) -> i64 {
    return secret ^ value;
}

fn prune(secret: i64) -> i64 {
    return secret % 16777216;
}

fn evolve(secret: i64) -> i64 {
    let mut secret = mix(secret, secret * 64);
    secret = prune(secret);
    secret = mix(secret, secret / 32);
    secret = prune(secret);
    secret = mix(secret, secret * 2048);
    secret = prune(secret);
    return secret;
}

struct SecretIterator {
    next: i64,
}

impl Iterator for SecretIterator {
    type Item = i64;

    fn next(&mut self) -> Option<Self::Item> {
        let current = self.next;
        self.next = evolve(self.next);
        Some(current)
    }
}

struct DiffIterator<I>
where
    I: Iterator<Item = i64>,
{
    it: I,
    current: Option<i64>,
}

impl<I> Iterator for DiffIterator<I>
where
    I: Iterator<Item = i64>,
{
    type Item = i64;

    fn next(&mut self) -> Option<Self::Item> {
        if self.current.is_none() {
            self.current = self.it.next();
        }
        let current = self.current?;
        let next = self.it.next()?;
        self.current = Some(next);
        Some(next - current)
    }
}

fn price(value: i64) -> i64 {
    return value - ((value / 10) * 10);
}

fn secrets_iter(initial: i64) -> impl Iterator<Item = i64> {
    return SecretIterator { next: initial };
}

fn difference_iter(it: impl Iterator<Item = i64>) -> impl Iterator<Item = i64> {
    return DiffIterator { it, current: None };
}

fn main() {
    let file = File::open("input").unwrap();
    let reader = BufReader::new(file);

    let mut price_diffs: Vec<Vec<i64>> = vec![];
    let mut seller_prices: Vec<Vec<i64>> = vec![];

    for line in reader.lines() {
        let startval = line.unwrap().parse().unwrap();
        let prices: Vec<i64> = secrets_iter(startval).map(price).take(2000).collect();
        price_diffs.push(difference_iter(prices.iter().copied()).collect());
        seller_prices.push(prices.iter().skip(1).copied().collect());
    }

    let mut maps: Vec<HashMap<[i64; 4], i64>> = vec![];
    for j in 0..price_diffs.len() {
        let mut map: HashMap<[i64; 4], i64> = HashMap::new();
        for i in 0..price_diffs[0].len() - 4 {
            let diff: [i64; 4] = [
                price_diffs[j][i],
                price_diffs[j][i + 1],
                price_diffs[j][i + 2],
                price_diffs[j][i + 3],
            ];
            let price = seller_prices[j][i + 3];
            if map.contains_key(&diff) {
                continue;
            }
            map.insert(diff, price);
        }
        maps.push(map);
    }

    // combine all the maps
    let mut map: HashMap<[i64; 4], i64> = HashMap::new();
    for m in maps.iter() {
        for (k, v) in m.iter() {
            if map.contains_key(k) {
                map.insert(*k, map[k] + v);
            } else {
                map.insert(*k, *v);
            }
        }
    }

    let total = map
        .iter()
        .max_by(|a, b| a.1.cmp(b.1))
        .map(|(_, v)| v)
        .unwrap();

    println!("{}", total);
}
