#!/usr/bin/env ruby

Vec2 = Struct.new(:x, :y)
Robot = Struct.new(:pos, :vel)
Rect = Struct.new(:min, :max)

$w = 101
$h = 103
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

def render(robots)
  lines = (0..$h).map{|y| " " * $w}
  robots.each {|r| lines[r.pos.y][r.pos.x] = 'X'}
  tree = lines.any? {|line| line.include? "XXXXXXXXXX"}
    lines.each {|line| 
      puts(line)
    }
  if tree
    exit
  end
end

robots = []
IO.readlines('input', chomp: true).each { |line|
  match = /p=(?<px>-?[0-9]+),(?<py>-?[0-9]+) v=(?<vx>-?[0-9]+),(?<vy>-?[0-9]+)/.match(line)
  p = Vec2.new(Integer(match[:px]), Integer(match[:py]))
  v = Vec2.new(Integer(match[:vx]), Integer(match[:vy]))
  robot = Robot.new(p, v)
  robots.push(robot)
}

10000.times { |i|
  puts(i)
  robots = robots.map { |robot| move(robot, 1) }
  render(robots)
}
