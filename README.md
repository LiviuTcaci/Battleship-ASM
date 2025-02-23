# Battleship (Vaporase) in Assembly

This repository contains an implementation of a Battleship-like game, called **"Vaporase"**, written entirely in Assembly. The project leverages the `canvas_framework` and `Assembly-from-image-masetr` tools for graphics rendering.

## Overview

The game displays a fixed grid (currently 10×10) and simulates the classic Battleship mechanics. When a user clicks on a cell:
- If the cell represents water, it is filled with blue.
- If the cell contains part of a ship, it is filled with red.
  
At every step, the game updates and shows three counters:
- **Remaining ship parts:** The number of undiscovered parts of the ships.
- **Successful hits:** The count of cells where a ship was hit.
- **Misses:** The count of clicks on water.

## Features

- **Graphical Grid:**  
  A fixed grid is drawn on screen with cells of 48×48 pixels, representing a 10×10 matrix.

- **Click Handling:**  
  The game detects clicks on cells and changes their appearance based on whether water or a ship part is present.

- **Counters Display:**  
  Counters for remaining ship parts, successful hits, and misses are continuously updated and rendered.

- **Graphics and Text Rendering:**  
  Uses included files (e.g., `boat.inc`, `water.inc`, `digits.inc`, `letters.inc`, etc.) to draw images and text on a custom canvas.

## Limitations

While the core mechanics are implemented, the project does **not** fully meet all of the original requirements:

- **Random Ship Placement:**  
  Ship positions are hard-coded rather than generated randomly at runtime.

- **Customizable Grid Dimensions:**  
  The grid dimensions are fixed at 10×10. The feature to allow the user to specify the number of rows (n) and columns (m) at the start of the program is not implemented.

## Directory Structure
```
.
├── Battleship.asm          # Main assembly source code
├── Battleship.exe          # Compiled executable
├── History                 # Previous versions and experimental files
│   ├── VAPORASE.asm
│   ├── VAPORASE0.asm
│   ├── VAPORASE1.asm
│   ├── VAPORASE2.asm
│   ├── VAPORASE3.asm
│   ├── VAPORASE4.asm
│   ├── VAPORASE5.asm
│   └── VAPORASE6(5x5).asm
├── boat.inc                # Ship graphical data
├── canvas.dll              # Canvas framework dynamic library
├── canvas.lib              # Canvas framework static library
├── digits.inc              # Digit graphics for text rendering
├── letters.inc             # Letter graphics for text rendering
├── picture.inc             # Additional graphics assets
├── water.inc               # Water graphics asset
├── win1.inc                # Winning graphic assets
├── win2.inc
├── win3.inc
└── win4.inc
```

## Tools Used

- **canvas_framework:** For initializing the drawing canvas and handling low-level graphics operations.
- **Assembly-from-image-masetr:** For converting image data into assembly include files.

## Build and Run Instructions

1. **Prerequisites:**  
   - MASM (Microsoft Macro Assembler) installed.
   - The `canvas_framework` libraries (`canvas.dll` and `canvas.lib`) available.
   - A Windows environment capable of running the generated executable.

2. **Compilation:**  
   Use MASM to compile `Battleship.asm`. For example:
   ```batch
   ml /c /coff Battleship.asm
   link /subsystem:windows Battleship.obj canvas.lib

(Adjust the commands as necessary for your development environment.)
	3.	Execution:
Run the generated Battleship.exe to launch the game.

Future Improvements
	
 •	Random Ship Placement:
Implement logic to randomly generate ship positions on each run.
	
 •	Custom Grid Dimensions:
Allow the user to specify grid dimensions (n×m) at the beginning of the program.

 •	Enhanced User Interface:
Improve the visual feedback and potentially add additional game features.


Enjoy playing Battleship in Assembly!

