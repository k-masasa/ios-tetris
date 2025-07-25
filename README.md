# iOS Tetris

A complete Tetris game implementation for iOS using Swift and SwiftUI.

## Features

- **Classic Tetris Gameplay**: All 7 standard tetrominoes (I, O, T, S, Z, J, L)
- **Touch Controls**: 
  - Swipe left/right to move pieces
  - Tap to rotate pieces
  - Swipe down for hard drop
- **Progressive Difficulty**: Speed increases with level progression
- **Scoring System**: Standard Tetris scoring (40/100/300/1200 × level)
- **Universal App**: Supports both iPhone and iPad

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Open `Tetris.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project

## How to Play

- **Move**: Swipe left or right on the game board
- **Rotate**: Tap on the game board
- **Hard Drop**: Swipe down on the game board
- **Pause/Resume**: Use the pause button

## Architecture

- Built with SwiftUI for modern, declarative UI
- MVVM architecture pattern
- ObservableObject for reactive state management
- No external dependencies
