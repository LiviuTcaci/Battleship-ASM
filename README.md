# Battleship Game in Assembly

A classic Battleship game implemented in x86 Assembly language using a graphical interface. This project demonstrates low-level programming concepts while creating an engaging game experience.

## Overview

This implementation of Battleship features:
- A 10x10 grid game board
- Visual representation of hits and misses
- Game statistics tracking (remaining boats, successful hits, misses)
- Win condition detection with celebration graphics

## How to Play

1. Run the executable `Battleship.exe`
2. Click on cells in the grid to guess where enemy ships are located
3. Blue cells indicate water (misses)
4. Red cells indicate successful hits on ships
5. The game tracks:
   - Number of remaining boats
   - Number of successful hits
   - Number of misses
6. Find and destroy all enemy ships to win!

## Technical Implementation

### Architecture
The game is built with x86 Assembly and uses a custom canvas framework for drawing the graphical interface. The main components include:

- Matrix-based game logic (10x10 grid)
- Mouse event handling
- Custom graphics rendering
- Game state management

### Key Components

- **Battleship.asm**: Main game code
- **canvas.dll/lib**: Framework for graphics
- **digits.inc/letters.inc**: Character rendering
- **boat.inc/water.inc**: Game graphics
- **win1-4.inc**: Victory animation graphics

### Technical Features

- Direct memory manipulation for graphics
- Event-driven architecture
- Manual hit detection and collision mapping
- Custom drawing procedures for text and images

## Building from Source

To build the project:

1. Ensure you have an x86 Assembly compiler (MASM, TASM, etc.)
2. Include all the necessary .inc files
3. Link with the canvas.lib library
4. Compile the Battleship.asm file

Example compilation command (using MASM):
```
ml /c /coff Battleship.asm
link /subsystem:windows Battleship.obj canvas.lib
```

## Tools Used

- Assembly language (x86)
- canvas_framework for graphics rendering
- Assembly-from-image-master for converting graphics to Assembly code

## Project Structure

```
.
├── Battleship.asm       # Main source code
├── Battleship.exe       # Executable
├── *.inc                # Include files for graphics and characters
├── canvas.dll           # Runtime library
└── canvas.lib           # Link library
```

## Future Enhancements

Planned improvements for the project include:
- Random ship placement at game start
- Configurable grid size (n×m dimensions)
- Difficulty levels
- Game reset functionality without restarting
- Sound effects for hits and misses
- Game timer and score tracking

## License

This project is available for educational purposes.
