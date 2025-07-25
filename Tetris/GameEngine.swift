import SwiftUI
import Combine

enum GameState {
    case playing
    case paused
    case gameOver
    case menu
}

class GameEngine: ObservableObject {
    @Published var board = GameBoard()
    @Published var currentTetromino: Tetromino?
    @Published var nextTetromino: Tetromino?
    @Published var score = 0
    @Published var level = 1
    @Published var lines = 0
    @Published var gameState = GameState.menu
    @Published var showLineClearAnimation = false
    
    private var gameTimer: Timer?
    private var dropInterval: TimeInterval = 1.0
    
    init() {
        resetGame()
    }
    
    func startGame() {
        gameState = .playing
        resetGame()
        spawnNewTetromino()
        startGameTimer()
    }
    
    func pauseGame() {
        if gameState == .playing {
            gameState = .paused
            stopGameTimer()
        }
    }
    
    func resumeGame() {
        if gameState == .paused {
            gameState = .playing
            startGameTimer()
        }
    }
    
    func resetGame() {
        board = GameBoard()
        currentTetromino = nil
        nextTetromino = generateRandomTetromino()
        score = 0
        level = 1
        lines = 0
        showLineClearAnimation = false
        stopGameTimer()
    }
    
    private func startGameTimer() {
        stopGameTimer()
        gameTimer = Timer.scheduledTimer(withTimeInterval: dropInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                self.dropTetromino()
            }
        }
    }
    
    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func generateRandomTetromino() -> Tetromino {
        let type = TetrominoType.allCases.randomElement()!
        return Tetromino(type: type)
    }
    
    private func spawnNewTetromino() {
        currentTetromino = nextTetromino
        nextTetromino = generateRandomTetromino()
        
        // Check if the new tetromino can be placed
        if let tetromino = currentTetromino, !board.isValidPosition(for: tetromino) {
            gameOver()
        }
    }
    
    func dropTetromino() {
        guard gameState == .playing, let tetromino = currentTetromino else { return }
        
        let movedTetromino = tetromino.moved(dx: 0, dy: 1)
        
        if board.isValidPosition(for: movedTetromino) {
            currentTetromino = movedTetromino
        } else {
            // Tetromino has landed
            board.place(tetromino: tetromino)
            let linesCleared = board.clearFullLines()
            
            if linesCleared > 0 {
                // Show line clear animation
                showLineClearAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showLineClearAnimation = false
                }
            }
            
            updateScore(linesCleared: linesCleared)
            
            if board.isGameOver() {
                gameOver()
            } else {
                spawnNewTetromino()
            }
        }
    }
    
    func moveTetromino(dx: Int, dy: Int = 0) {
        guard gameState == .playing, let tetromino = currentTetromino else { return }
        
        let movedTetromino = tetromino.moved(dx: dx, dy: dy)
        
        if board.isValidPosition(for: movedTetromino) {
            currentTetromino = movedTetromino
        }
    }
    
    func rotateTetromino() {
        guard gameState == .playing, let tetromino = currentTetromino else { return }
        
        let rotatedTetromino = tetromino.rotated()
        
        if board.isValidPosition(for: rotatedTetromino) {
            currentTetromino = rotatedTetromino
        }
    }
    
    func hardDrop() {
        guard gameState == .playing, let tetromino = currentTetromino else { return }
        
        var droppedTetromino = tetromino
        var dropDistance = 0
        
        while board.isValidPosition(for: droppedTetromino.moved(dx: 0, dy: 1)) {
            droppedTetromino = droppedTetromino.moved(dx: 0, dy: 1)
            dropDistance += 1
        }
        
        // Add bonus points for hard drop
        score += dropDistance * 2
        
        currentTetromino = droppedTetromino
        dropTetromino() // This will place the piece immediately
    }
    
    private func updateScore(linesCleared: Int) {
        lines += linesCleared
        
        let baseScore = [0, 40, 100, 300, 1200]
        if linesCleared > 0 && linesCleared <= 4 {
            score += baseScore[linesCleared] * level
        }
        
        // Level up every 10 lines
        let newLevel = (lines / 10) + 1
        if newLevel > level {
            level = newLevel
            dropInterval = max(0.1, 1.0 - Double(level - 1) * 0.1)
            if gameState == .playing {
                startGameTimer() // Restart timer with new interval
            }
        }
    }
    
    private func gameOver() {
        gameState = .gameOver
        stopGameTimer()
    }
}