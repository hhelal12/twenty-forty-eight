import 'dart:math';


final Random _random = Random();

void spawnRandomTile(List<int> grid) {
  //  find empty positions
  List<int> emptyIndices = [];
  for (int i = 0; i < grid.length; i++) {
    if (grid[i] == 0) {
      emptyIndices.add(i);
    }
  }

  // Pick a random empty cell
  if (emptyIndices.isNotEmpty) {
    int randomIndex = emptyIndices[_random.nextInt(emptyIndices.length)];

    grid[randomIndex] = _random.nextInt(10) == 0 ? 4 : 2;
  }
}


int moveLeft(List<int> grid, int score) {
  for (int rowStart = 0; rowStart < 16; rowStart += 4) {
    List<int> row = grid.sublist(rowStart, rowStart + 4);

    // slide left 
    row = row.where((n) => n != 0).toList();

    // merge
    for (int i = 0; i < row.length - 1; i++) {
      if (row[i] == row[i + 1]) {
        row[i] *= 2;
        score += row[i]; 
        row[i + 1] = 0;
      }
    }
    row = row.where((n) => n != 0).toList();

    // fill with zeros
    while (row.length < 4) {
      row.add(0);
    }

    //  back into grid
    for (int i = 0; i < 4; i++) {
      grid[rowStart + i] = row[i];
    }
  }

  return score; 
}
int moveRight(List<int> grid, int score){
  for (int rowStart = 0; rowStart < 16; rowStart += 4) {
    List<int> row = grid.sublist(rowStart, rowStart + 4);

    row = row.reversed.toList();

    row = row.where((n) => n != 0).toList();
    for (int i = 0; i < row.length - 1; i++) {
      if (row[i] == row[i + 1]) {
        row[i] *= 2;
        score += row[i]; 
        row[i + 1] = 0;
      }
    }
    row = row.where((n) => n != 0).toList();

    while (row.length < 4) {
      row.add(0);
    }
    row = row.reversed.toList();
    for (int i = 0; i < 4; i++) {
      grid[rowStart + i] = row[i];
    }
  }
  return score;
}

int moveUp(List<int> grid, int score){
  for (int col = 0; col < 4; col++) {
    // extract column
    List<int> column = [
      grid[col],
      grid[col + 4],
      grid[col + 8],
      grid[col + 12]
    ];

    // remove zeros
    column = column.where((n) => n != 0).toList();

    // merge
    for (int i = 0; i < column.length - 1; i++) {
      if (column[i] == column[i + 1]) {
        column[i] *= 2;
        score += column[i];
        column[i + 1] = 0;
      }
    }

    // remove zeros again after merge
    column = column.where((n) => n != 0).toList();

    while (column.length < 4) column.add(0);

    // put column back into grid
    grid[col] = column[0];
    grid[col + 4] = column[1];
    grid[col + 8] = column[2];
    grid[col + 12] = column[3];
  }

  return score;
}

int moveDown(List<int> grid, int score) {
  for (int col = 0; col < 4; col++) {
    List<int> column = [
      grid[col],
      grid[col + 4],
      grid[col + 8],
      grid[col + 12]
    ];

    column = column.reversed.toList();
    column = column.where((n) => n != 0).toList();

    for (int i = 0; i < column.length - 1; i++) {
      if (column[i] == column[i + 1]) {
        column[i] *= 2;
        score += column[i];
        column[i + 1] = 0;
      }
    }

    column = column.where((n) => n != 0).toList();

    while (column.length < 4) column.add(0);
   
    column = column.reversed.toList();
    grid[col] = column[0];
    grid[col + 4] = column[1];
    grid[col + 8] = column[2];
    grid[col + 12] = column[3];
  }

  return score;
}


// gameover part

bool hasEmptyCell(List<int> grid) {
  return grid.contains(0);
}

bool canMerge(List<int> grid) {
  for (int rowStart = 0; rowStart < 16; rowStart += 4) {
    for (int i = 0; i < 3; i++) {
      if (grid[rowStart + i] == grid[rowStart + i + 1]) return true;
    }
  }

  for (int col = 0; col < 4; col++) {
    for (int i = 0; i < 3; i++) {
      if (grid[col + i * 4] == grid[col + (i + 1) * 4]) return true;
    }
  }

  return false;
}

bool isGameOver(List<int> grid) {
  return !hasEmptyCell(grid) && !canMerge(grid);
}
