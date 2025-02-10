use std::{
    fs::File,
    io::{BufRead, BufReader},
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

fn evolve_n(secret: i64, n: u16) -> i64 {
    let mut secret = secret;
    for _ in 0..n {
        secret = evolve(secret);
    }
    return secret;
}

fn main() {
    let file = File::open("input").unwrap();
    let reader = BufReader::new(file);

    let mut total = 0;
    for line in reader.lines() {
        let startval = line.unwrap().parse().unwrap();
        total += evolve_n(startval, 2000);
    }
    println!("{}", total);
}
