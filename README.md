# SPARK Tic-Tac-Toe

A SPARK-compliant implementation of Tic-Tac-Toe game logic with undo functionality.

## Project Structure

```
tictactoe/
├── tictactoe.gpr    # GNAT Project File
└── src/
    └── tictactoe.adb # Main procedure with all game logic
```

## Features

- Full SPARK compliance with `SPARK_Mode => On`
- No I/O operations (compatible with SPARK restrictions)
- Game simulation without user input
- Stack-based undo functionality
- Computer AI with winning strategy
- All original Tic-Tac-Toe logic preserved

## Verification

Run SPARK proof with:

```bash
gnatprove -P tictactoe.gpr --level=4 --timeout=0 --no-inlining --report=all
```

Expected result: **0 warnings, 0 errors**

## Build

Compile with GNAT:

```bash
gnatmake -P tictactoe.gpr
```

## Implementation Details

- **Types**: `Slot` (Empty, Player, Computer), `Pos`, `Board`
- **Stack**: Internal board stack for undo operations (max size: 9)
- **AI**: Computer plays optimally, checks for winning moves
- **Game Loop**: Simulates alternating player/computer moves

## Version History

- **v0.01** - Initial SPARK-compliant restructuring (1 .adb, 1 .gpr)
