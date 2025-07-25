import SwiftUI

struct GameBoard {
    static let width = 10
    static let height = 20
    
    private var grid: [[Color?]]
    
    init() {
        grid = Array(repeating: Array(repeating: nil, count: Self.width), count: Self.height)
    }
    
    func isEmpty(at x: Int, y: Int) -> Bool {
        guard x >= 0 && x < Self.width && y >= 0 && y < Self.height else {
            return false
        }
        return grid[y][x] == nil
    }
    
    func isValidPosition(for tetromino: Tetromino) -> Bool {
        let positions = tetromino.getBlockPositions()
        
        for (x, y) in positions {
            if x < 0 || x >= Self.width || y >= Self.height {
                return false
            }
            if y >= 0 && !isEmpty(at: x, y: y) {
                return false
            }
        }
        
        return true
    }
    
    mutating func place(tetromino: Tetromino) {
        let positions = tetromino.getBlockPositions()
        
        for (x, y) in positions {
            if y >= 0 && y < Self.height && x >= 0 && x < Self.width {
                grid[y][x] = tetromino.color
            }
        }
    }
    
    mutating func clearFullLines() -> Int {
        var linesCleared = 0
        var newGrid: [[Color?]] = []
        
        for row in grid {
            if !row.allSatisfy({ $0 != nil }) {
                newGrid.append(row)
            } else {
                linesCleared += 1
            }
        }
        
        // Add empty rows at the top
        while newGrid.count < Self.height {
            newGrid.insert(Array(repeating: nil, count: Self.width), at: 0)
        }
        
        grid = newGrid
        return linesCleared
    }
    
    func getColor(at x: Int, y: Int) -> Color? {
        guard x >= 0 && x < Self.width && y >= 0 && y < Self.height else {
            return nil
        }
        return grid[y][x]
    }
    
    func isGameOver() -> Bool {
        // Check if any block is placed in the top rows
        for x in 0..<Self.width {
            if grid[0][x] != nil || grid[1][x] != nil {
                return true
            }
        }
        return false
    }
}