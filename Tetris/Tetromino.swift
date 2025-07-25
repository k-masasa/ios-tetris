import SwiftUI

enum TetrominoType: CaseIterable {
    case I, O, T, S, Z, J, L
    
    var color: Color {
        switch self {
        case .I: return .cyan
        case .O: return .yellow
        case .T: return .purple
        case .S: return .green
        case .Z: return .red
        case .J: return .blue
        case .L: return .orange
        }
    }
    
    var blocks: [[[Bool]]] {
        switch self {
        case .I:
            return [
                [[true, true, true, true]],
                [[true], [true], [true], [true]]
            ]
        case .O:
            return [
                [[true, true], [true, true]]
            ]
        case .T:
            return [
                [[false, true, false], [true, true, true]],
                [[true, false], [true, true], [true, false]],
                [[true, true, true], [false, true, false]],
                [[false, true], [true, true], [false, true]]
            ]
        case .S:
            return [
                [[false, true, true], [true, true, false]],
                [[true, false], [true, true], [false, true]]
            ]
        case .Z:
            return [
                [[true, true, false], [false, true, true]],
                [[false, true], [true, true], [true, false]]
            ]
        case .J:
            return [
                [[true, false, false], [true, true, true]],
                [[true, true], [true, false], [true, false]],
                [[true, true, true], [false, false, true]],
                [[false, true], [false, true], [true, true]]
            ]
        case .L:
            return [
                [[false, false, true], [true, true, true]],
                [[true, false], [true, false], [true, true]],
                [[true, true, true], [true, false, false]],
                [[true, true], [false, true], [false, true]]
            ]
        }
    }
}

struct Tetromino {
    let type: TetrominoType
    var position: CGPoint
    var rotationIndex: Int
    
    init(type: TetrominoType, position: CGPoint = CGPoint(x: 3, y: 0)) {
        self.type = type
        self.position = position
        self.rotationIndex = 0
    }
    
    var currentShape: [[Bool]] {
        return type.blocks[rotationIndex]
    }
    
    var color: Color {
        return type.color
    }
    
    func rotated() -> Tetromino {
        var newTetromino = self
        newTetromino.rotationIndex = (rotationIndex + 1) % type.blocks.count
        return newTetromino
    }
    
    func moved(dx: Int, dy: Int) -> Tetromino {
        var newTetromino = self
        newTetromino.position.x += CGFloat(dx)
        newTetromino.position.y += CGFloat(dy)
        return newTetromino
    }
    
    func getBlockPositions() -> [(Int, Int)] {
        var positions: [(Int, Int)] = []
        let shape = currentShape
        
        for (row, rowData) in shape.enumerated() {
            for (col, hasBlock) in rowData.enumerated() {
                if hasBlock {
                    let x = Int(position.x) + col
                    let y = Int(position.y) + row
                    positions.append((x, y))
                }
            }
        }
        
        return positions
    }
}