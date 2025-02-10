#include <stdio.h>
#include <stdlib.h>

#define MAP_WIDTH 100  // 20 for the example
#define MAP_HEIGHT 50  // 10 for the example

typedef enum { wall, empty, lbox, rbox, robot } cell_t;
typedef enum { up, down, left, right } direction_t;

typedef struct {
  cell_t cells[MAP_HEIGHT][MAP_WIDTH];
  int robot_x;
  int robot_y;
} map_t;

typedef struct moves {
  direction_t direction;
  struct moves *next;
} moves_t;

void parse_map(FILE *file, map_t *map, moves_t *moves) {
  for (int y = 0; y < MAP_HEIGHT; y++) {
    for (int x = 0; x < MAP_WIDTH; x += 2) {
      char c = fgetc(file);
      switch (c) {
        case '#':
          map->cells[y][x] = wall;
          map->cells[y][x + 1] = wall;
          break;
        case '.':
          map->cells[y][x] = empty;
          map->cells[y][x + 1] = empty;
          break;
        case 'O':
          map->cells[y][x] = lbox;
          map->cells[y][x + 1] = rbox;
          break;
        case '@':
          map->cells[y][x] = robot;
          map->cells[y][x + 1] = empty;
          map->robot_x = x;
          map->robot_y = y;
          break;
        case '\n':
          break;
      }
    }
    fgetc(file);
  }
  moves_t *prev = NULL;
  while (1) {
    char c = fgetc(file);
    if (c == EOF) {
      break;
    }
    if (c == '\n') {
      continue;
    }
    moves_t *move;
    if (prev == NULL) {
      move = moves;
    } else {
      move = (moves_t *)malloc(sizeof(moves_t));
    }
    switch (c) {
      case '^':
        move->direction = up;
        break;
      case 'v':
        move->direction = down;
        break;
      case '<':
        move->direction = left;
        break;
      case '>':
        move->direction = right;
        break;
    }
    if (prev != NULL) {
      prev->next = move;
    }
    prev = move;
  }
}

void apply_direction(int *x, int *y, direction_t direction) {
  switch (direction) {
    case up:
      *y -= 1;
      break;
    case down:
      *y += 1;
      break;
    case left:
      *x -= 1;
      break;
    case right:
      *x += 1;
      break;
    default:
      break;
  }
}

int check_move(map_t *map, int x, int y, direction_t direction) {
  if (map->cells[y][x] == wall) {
    return 0;
  }

  if (map->cells[y][x] == empty) {
    return 1;
  }

  if (map->cells[y][x] == lbox && (direction == up || direction == down)) {
    int l_target_x = x;
    int l_target_y = y;
    int r_target_x = x + 1;
    int r_target_y = y;
    apply_direction(&l_target_x, &l_target_y, direction);
    apply_direction(&r_target_x, &r_target_y, direction);
    if (check_move(map, l_target_x, l_target_y, direction) == 1 &&
        check_move(map, r_target_x, r_target_y, direction) == 1) {
      return 1;
    }
    return 0;
  }

  if (map->cells[y][x] == rbox && (direction == up || direction == down)) {
    int r_target_x = x;
    int r_target_y = y;
    int l_target_x = x - 1;
    int l_target_y = y;
    apply_direction(&r_target_x, &r_target_y, direction);
    apply_direction(&l_target_x, &l_target_y, direction);
    if (check_move(map, r_target_x, r_target_y, direction) == 1 &&
        check_move(map, l_target_x, l_target_y, direction) == 1) {
      return 1;
    }
    return 0;
  }

  if (map->cells[y][x] == robot || map->cells[y][x] == lbox ||
      map->cells[y][x] == rbox) {
    int target_x = x;
    int target_y = y;
    apply_direction(&target_x, &target_y, direction);
    if (check_move(map, target_x, target_y, direction) == 1) {
      return 1;
    }
  }

  return 0;
}

void do_move(map_t *map, int x, int y, direction_t direction) {
  if (map->cells[y][x] == wall) {
    return;
  }

  if (map->cells[y][x] == empty) {
    return;
  }

  if (check_move(map, x, y, direction) == 0) {
    return;
  }

  if (map->cells[y][x] == lbox && (direction == up || direction == down)) {
    int l_target_x = x;
    int l_target_y = y;
    int r_target_x = x + 1;
    int r_target_y = y;
    apply_direction(&l_target_x, &l_target_y, direction);
    do_move(map, l_target_x, l_target_y, direction);
    apply_direction(&r_target_x, &r_target_y, direction);
    do_move(map, r_target_x, r_target_y, direction);
    map->cells[l_target_y][l_target_x] = map->cells[y][x];
    map->cells[r_target_y][r_target_x] = map->cells[y][x + 1];
    map->cells[y][x] = empty;
    map->cells[y][x + 1] = empty;
    return;
  }

  if (map->cells[y][x] == rbox && (direction == up || direction == down)) {
    int r_target_x = x;
    int r_target_y = y;
    int l_target_x = x - 1;
    int l_target_y = y;
    apply_direction(&r_target_x, &r_target_y, direction);
    do_move(map, r_target_x, r_target_y, direction);
    apply_direction(&l_target_x, &l_target_y, direction);
    do_move(map, l_target_x, l_target_y, direction);
    map->cells[r_target_y][r_target_x] = map->cells[y][x];
    map->cells[l_target_y][l_target_x] = map->cells[y][x - 1];
    map->cells[y][x] = empty;
    map->cells[y][x - 1] = empty;
    return;
  }

  if (map->cells[y][x] == robot || map->cells[y][x] == lbox ||
      map->cells[y][x] == rbox) {
    int target_x = x;
    int target_y = y;
    apply_direction(&target_x, &target_y, direction);
    do_move(map, target_x, target_y, direction);
    if (map->cells[y][x] == robot) {
      apply_direction(&map->robot_x, &map->robot_y, direction);
    }
    map->cells[target_y][target_x] = map->cells[y][x];
    map->cells[y][x] = empty;
    return;
  }
}

int box_sum(map_t *map) {
  int sum = 0;
  for (int y = 0; y < MAP_HEIGHT; y++) {
    for (int x = 0; x < MAP_WIDTH; x++) {
      if (map->cells[y][x] == lbox) {
        sum += 100 * y + x;
      }
    }
  }
  return sum;
}

void print_map(map_t *map) {
  for (int y = 0; y < MAP_HEIGHT; y++) {
    for (int x = 0; x < MAP_WIDTH; x++) {
      switch (map->cells[y][x]) {
        case wall:
          printf("#");
          break;
        case empty:
          printf(".");
          break;
        case lbox:
          printf("[");
          break;
        case rbox:
          printf("]");
          break;
        case robot:
          printf("@");
          break;
        default:
          break;
      }
    }
    printf("\n");
  }
}

void print_direction(direction_t direction) {
  switch (direction) {
    case up:
      printf("up\n");
      break;
    case down:
      printf("down\n");
      break;
    case left:
      printf("left\n");
      break;
    case right:
      printf("right\n");
      break;
  }
}

int main() {
  map_t map;
  moves_t moves;

  FILE *file = fopen("input", "r");
  parse_map(file, &map, &moves);
  fclose(file);

  moves_t *move = &moves;
  while (move != NULL) {
    // print_direction(move->direction);
    do_move(&map, map.robot_x, map.robot_y, move->direction);
    // printf("Robot at (%d, %d)\n", map.robot_x, map.robot_y);
    // print_map(&map);

    move = move->next;
  }

  int sum = box_sum(&map);

  printf("%d\n", sum);

  return 0;
}
