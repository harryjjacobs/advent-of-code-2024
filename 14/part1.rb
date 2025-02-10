#!/usr/bin/env ruby

Vec2 = Struct.new(:x, :y)
Robot = Struct.new(:pos, :vel)
Rect = Struct.new(:min, :max)

$w = 101
$h = 103

# example input:
# $w = 11
# $h = 7

def wrap(robot)

  robot.pos.x = robot.pos.x.modulo($w)
  robot.pos.y = robot.pos.y.modulo($h)
  return robot
end

def move(robot, dt)
  robot.pos.x += robot.vel.x * dt
  robot.pos.y += robot.vel.y * dt
  robot = wrap(robot)
  return robot
end

def rect_contains(rect, pos)
  return (pos.x >= rect.min.x and pos.x < rect.max.x and pos.y >= rect.min.y and pos.y < rect.max.y)
end

def quad_count(robots)
  tl = Rect.new(Vec2.new(0, 0), Vec2.new(($w - 1) / 2, $h / 2))
  tr = Rect.new(Vec2.new(($w + 1) / 2, 0), Vec2.new($w, $h / 2))
  bl = Rect.new(Vec2.new(0, ($h + 1) / 2), Vec2.new(($w - 1) / 2, $h))
  br = Rect.new(Vec2.new(($w + 1) / 2, ($h + 1) / 2), Vec2.new($w, $h))
  return robots.count {|r| rect_contains(tl, r.pos)} *
          robots.count {|r| rect_contains(tr, r.pos)} *
          robots.count {|r| rect_contains(bl, r.pos)} *
          robots.count {|r| rect_contains(br, r.pos)}
end

robots = []
IO.readlines('input', chomp: true).each { |line|
  match = /p=(?<px>-?[0-9]+),(?<py>-?[0-9]+) v=(?<vx>-?[0-9]+),(?<vy>-?[0-9]+)/.match(line)
  p = Vec2.new(Integer(match[:px]), Integer(match[:py]))
  v = Vec2.new(Integer(match[:vx]), Integer(match[:vy]))
  robot = Robot.new(p, v)
  robots.push(robot)
}

robots = robots.map { |robot| move(robot, 100) }

puts quad_count(robots)