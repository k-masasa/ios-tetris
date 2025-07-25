import SwiftUI

struct GameView: View {
    @StateObject private var gameEngine = GameEngine()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if gameEngine.gameState == .menu {
                    MenuView(gameEngine: gameEngine)
                } else {
                    MainGameView(gameEngine: gameEngine, geometry: geometry)
                }
            }
        }
    }
}

struct MenuView: View {
    let gameEngine: GameEngine
    @State private var showInstructions = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("TETRIS")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                Button("Start Game") {
                    gameEngine.startGame()
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Instructions") {
                    showInstructions = true
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showInstructions) {
            InstructionsView()
        }
    }
}

struct InstructionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to Play")
                    .font(.title)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 15) {
                    InstructionRow(title: "Move Left/Right", description: "Swipe left or right on the game board")
                    InstructionRow(title: "Rotate Piece", description: "Tap on the game board")
                    InstructionRow(title: "Hard Drop", description: "Swipe down on the game board")
                    InstructionRow(title: "Pause/Resume", description: "Use the pause button")
                    
                    Divider()
                    
                    Text("Scoring:")
                        .font(.headline)
                    Text("• 1 line: 40 × level")
                    Text("• 2 lines: 100 × level")
                    Text("• 3 lines: 300 × level")
                    Text("• 4 lines: 1200 × level")
                    Text("• Hard drop: 2 points per cell")
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionRow: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct MainGameView: View {
    @ObservedObject var gameEngine: GameEngine
    let geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 20) {
            // Score and info
            HStack {
                VStack(alignment: .leading) {
                    Text("Score: \(gameEngine.score)")
                    Text("Level: \(gameEngine.level)")
                    Text("Lines: \(gameEngine.lines)")
                }
                .foregroundColor(.white)
                .font(.headline)
                
                Spacer()
                
                // Next piece preview
                NextPieceView(tetromino: gameEngine.nextTetromino)
            }
            .padding(.horizontal)
            
            // Game board with gesture controls
            TetrisBoard(gameEngine: gameEngine)
                .frame(maxWidth: min(geometry.size.width * 0.8, 300))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            if abs(horizontalAmount) > abs(verticalAmount) {
                                // Horizontal swipe
                                if horizontalAmount > 50 {
                                    gameEngine.moveTetromino(dx: 1)
                                } else if horizontalAmount < -50 {
                                    gameEngine.moveTetromino(dx: -1)
                                }
                            } else {
                                // Vertical swipe
                                if verticalAmount > 50 {
                                    gameEngine.hardDrop()
                                }
                            }
                        }
                )
                .onTapGesture {
                    if gameEngine.gameState == .playing {
                        gameEngine.rotateTetromino()
                    } else if gameEngine.gameState == .paused {
                        gameEngine.resumeGame()
                    }
                }
            
            // Controls
            GameControls(gameEngine: gameEngine)
            
            // Game Over overlay
            if gameEngine.gameState == .gameOver {
                GameOverView(gameEngine: gameEngine)
            }
        }
    }
}

struct TetrisBoard: View {
    @ObservedObject var gameEngine: GameEngine
    
    var body: some View {
        GeometryReader { geometry in
            let blockSize = min(
                geometry.size.width / CGFloat(GameBoard.width),
                geometry.size.height / CGFloat(GameBoard.height)
            )
            
            ZStack {
                // Board background
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .border(Color.white, width: 2)
                
                // Grid lines
                ForEach(0..<GameBoard.height, id: \.self) { row in
                    Rectangle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        .frame(width: geometry.size.width, height: blockSize)
                        .position(
                            x: geometry.size.width / 2,
                            y: CGFloat(row) * blockSize + blockSize / 2
                        )
                }
                
                ForEach(0..<GameBoard.width, id: \.self) { col in
                    Rectangle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        .frame(width: blockSize, height: geometry.size.height)
                        .position(
                            x: CGFloat(col) * blockSize + blockSize / 2,
                            y: geometry.size.height / 2
                        )
                }
                
                // Placed blocks
                ForEach(0..<GameBoard.height, id: \.self) { row in
                    ForEach(0..<GameBoard.width, id: \.self) { col in
                        if let color = gameEngine.board.getColor(at: col, y: row) {
                            Rectangle()
                                .fill(color)
                                .border(Color.white.opacity(0.3), width: 1)
                                .frame(width: blockSize, height: blockSize)
                                .position(
                                    x: CGFloat(col) * blockSize + blockSize / 2,
                                    y: CGFloat(row) * blockSize + blockSize / 2
                                )
                                .scaleEffect(gameEngine.showLineClearAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: gameEngine.showLineClearAnimation)
                        }
                    }
                }
                
                // Current falling tetromino
                if let tetromino = gameEngine.currentTetromino {
                    ForEach(Array(tetromino.getBlockPositions().enumerated()), id: \.offset) { index, position in
                        Rectangle()
                            .fill(tetromino.color)
                            .border(Color.white, width: 1)
                            .frame(width: blockSize, height: blockSize)
                            .position(
                                x: CGFloat(position.0) * blockSize + blockSize / 2,
                                y: CGFloat(position.1) * blockSize + blockSize / 2
                            )
                            .shadow(color: tetromino.color.opacity(0.6), radius: 2)
                    }
                }
                
                // Ghost piece (preview of where piece will land)
                if let tetromino = gameEngine.currentTetromino {
                    let ghostTetromino = getGhostPiece(for: tetromino)
                    ForEach(Array(ghostTetromino.getBlockPositions().enumerated()), id: \.offset) { index, position in
                        Rectangle()
                            .stroke(tetromino.color.opacity(0.3), lineWidth: 2)
                            .frame(width: blockSize, height: blockSize)
                            .position(
                                x: CGFloat(position.0) * blockSize + blockSize / 2,
                                y: CGFloat(position.1) * blockSize + blockSize / 2
                            )
                    }
                }
            }
        }
        .aspectRatio(
            CGFloat(GameBoard.width) / CGFloat(GameBoard.height),
            contentMode: .fit
        )
    }
    
    private func getGhostPiece(for tetromino: Tetromino) -> Tetromino {
        var ghostTetromino = tetromino
        
        while gameEngine.board.isValidPosition(for: ghostTetromino.moved(dx: 0, dy: 1)) {
            ghostTetromino = ghostTetromino.moved(dx: 0, dy: 1)
        }
        
        return ghostTetromino
    }
}

struct NextPieceView: View {
    let tetromino: Tetromino?
    
    var body: some View {
        VStack {
            Text("Next")
                .foregroundColor(.white)
                .font(.headline)
            
            if let tetromino = tetromino {
                let shape = tetromino.currentShape
                VStack(spacing: 2) {
                    ForEach(0..<shape.count, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<shape[row].count, id: \.self) { col in
                                Rectangle()
                                    .fill(shape[row][col] ? tetromino.color : Color.clear)
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                }
                .padding(10)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
            }
        }
    }
}

struct GameControls: View {
    @ObservedObject var gameEngine: GameEngine
    
    var body: some View {
        VStack(spacing: 20) {
            // Pause button
            Button(gameEngine.gameState == .paused ? "Resume" : "Pause") {
                if gameEngine.gameState == .paused {
                    gameEngine.resumeGame()
                } else {
                    gameEngine.pauseGame()
                }
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(Color.orange)
            .cornerRadius(10)
            
            Text("Gesture Controls:")
                .foregroundColor(.white)
                .font(.headline)
            
            HStack(spacing: 15) {
                VStack {
                    Text("⬅️➡️")
                        .font(.title2)
                    Text("Swipe to Move")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("👆")
                        .font(.title2)
                    Text("Tap to Rotate")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("⬇️")
                        .font(.title2)
                    Text("Swipe Down to Drop")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
        .padding()
    }
}

struct GameOverView: View {
    let gameEngine: GameEngine
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Score: \(gameEngine.score)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button("Play Again") {
                    gameEngine.startGame()
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Menu") {
                    gameEngine.resetGame()
                    gameEngine.gameState = .menu
                }
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.gray)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    GameView()
}