//
//  TetrisModel.swift
//  TetrisGame
//
//  Created by Nihal Syed on 2021-04-11.
//

import SwiftUI

class TetrisModel: ObservableObject {
    @Published var gboard: [[gameBlock?]]
    @Published var tetrisBlock: tetroBlock?
    var numRow: Int
    var numCol: Int
    var timer: Timer?
    var blockFallingSpeed: Double
    
    //initialises game board to have 30 rows and 20 columns and draws the game board
    init(numRows: Int = 30, numColumns: Int = 20) {
        self.numRow = numRows
        self.numCol = numColumns
        
        gboard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        blockFallingSpeed = 0.2
        resume()
    }
    
    var shade: tetroBlock? {
        guard var prevShade = tetrisBlock else { return nil }
        var shade = prevShade
        while(checkBlock(givenBlock: shade)) {
            prevShade = shade
            shade = prevShade.moveBy(row: -1, column: 0)
        }
        
        return prevShade
    }
    
    //function that keeps the game moving after each block spawns and is placed based on timer
    func resume() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: blockFallingSpeed, repeats: true, block: gameEngine)
    }
    
    //stops timer so game ends 
    func pause() {
        timer?.invalidate()
    }
    
    //called when block is dragged left
    func blockMoveL() -> Bool {
        return blockMove(rowOffset: 0, columnOffset: -1)
    }
    
    //called when block is dragged right
    func blockMoveR() -> Bool {
        return blockMove(rowOffset: 0, columnOffset: 1)
    }
    
    //called when block is moved down or dragged down
    func blockMoveD() -> Bool {
        return blockMove(rowOffset: -1, columnOffset: 0)
    }
    
    //base function to handle block moves
    func blockMove(rowOffset: Int, columnOffset: Int) -> Bool {
        guard let currBlock = tetrisBlock else { return false }
        
        let newBlock = currBlock.moveBy(row: rowOffset, column: columnOffset)
        if checkBlock(givenBlock: newBlock) {
            tetrisBlock = newBlock
            return true
        }
        
        return false
    }
    
    //function called when block is spawned and drops block until block is placed
    func blockFall() {
        while(blockMoveD()) { }
    }
    
    func blockRotation(clockwise: Bool) {
        guard let currBlock = tetrisBlock else { return }
        
        let blockBoyJB = currBlock.rotateBlock(clockwise: clockwise)
        let flips = currBlock.getKicks(clockwise: clockwise)
        
        for flip in flips {
            let block = blockBoyJB.moveBy(row: flip.row, column: flip.column)
            if checkBlock(givenBlock: block) {
                tetrisBlock = block
                return
            }
        }
    }
    
    func checkBlock(givenBlock: tetroBlock) -> Bool {
        for block in givenBlock.blocks {
            let column = givenBlock.blockOrigin.column + block.column
            if column < 0 || column >= numCol { return false }
            
            let row = givenBlock.blockOrigin.row + block.row
            if row < 0 || row >= numRow { return false }
            
            if gboard[column][row] != nil { return false }
        }
        return true
    }
    
    //function used to place block and stop fropping block
    func blockPlaced() {
        guard let currBlock = tetrisBlock else {
            return
        }
        
        for block in currBlock.blocks {
            let row = currBlock.blockOrigin.row + block.row
            if row < 0 || row >= numRow { continue }
            
            let col = currBlock.blockOrigin.column + block.column
            if col < 0 || col >= numCol { continue }
            
            gboard[col][row] = gameBlock(blockType: currBlock.blockType)
        }
        
        tetrisBlock = nil
    }
    //clear line along horizontal axis is full and drops down other filled lines down 1 rank
    func clearLines() -> Bool {
        var newBoard: [[gameBlock?]] = Array(repeating: Array(repeating: nil, count: numRow), count: numCol)
        var gboardUpdated = false
        var newRow = 0
        
        for row in 0...numRow-1 {
            var lineCleared = true
            for col in 0...numCol-1 {
                lineCleared = lineCleared && gboard[col][row] != nil
            }
            
            if !lineCleared {
                for col in 0...numCol-1 {
                    newBoard[col][newRow] = gboard[col][row]
                }
                newRow += 1
            }
            gboardUpdated = gboardUpdated || lineCleared
        }
        
        if gboardUpdated {
            gboard = newBoard
        }
        return gboardUpdated
    }
    
    //engine that is used to keep game moving and played, engine stops using pause method once game is over
    //spawns random block and makes them fall until they are placed on the board
    func gameEngine(timer: Timer) {
        if clearLines() {
            print("Line Cleared")
            return
        }
        
        guard tetrisBlock != nil else {
            print("Spawning new block")
            tetrisBlock = tetroBlock.makeNewBlock(numRow: numRow, numCol: numCol)
            if !checkBlock(givenBlock: tetrisBlock!) {
                print("Game over!")
                pause()
            }
            return
        }
        
        if blockMoveD() {
            print("Moving block down")
            return
        }
        
        print("Placing block")
        blockPlaced()
    }
    
}

//struct data type for all tetris blocks
struct tetroBlock {
    var blockOrigin: blockArea
    var blockType: BlockType
    var blockRotation: Int
    
    var blocks: [blockArea] {
        return tetroBlock.getBlocks(blockType: blockType, rotation: blockRotation)
    }
    
    static func makeNewBlock(numRow: Int, numCol: Int) -> tetroBlock {
        let blockType = BlockType.allCases.randomElement()!
        
        var rMax = 0
        for block in getBlocks(blockType: blockType) {
            rMax = max(rMax, block.row)
        }
        
        let blockOrigins = blockArea(row: numRow - 1 - rMax, column: (numCol-1)/2)
        return tetroBlock(blockOrigin: blockOrigins, blockType: blockType, blockRotation: 0)
    }
    
    func rotateBlock(clockwise: Bool) -> tetroBlock {
        return tetroBlock(blockOrigin: blockOrigin, blockType: blockType, blockRotation: blockRotation + (clockwise ? 1 : -1))
    }
    
    func moveBy(row: Int, column: Int) -> tetroBlock {
        let newOrigin = blockArea(row: blockOrigin.row + row, column: blockOrigin.column + column)
        return tetroBlock(blockOrigin: newOrigin, blockType: blockType, blockRotation: blockRotation)
    }
    
    static func getBlocks(blockType: BlockType, rotation: Int = 0) -> [blockArea] {
        let allBlocks = getAllBlocks(blockType: blockType)
        
        var index = rotation % allBlocks.count
        if (index < 0) { index += allBlocks.count}
        
        return allBlocks[index]
    }
    
    //creats different forms of blocks based on different cases specified in our enum
    static func getAllBlocks(blockType: BlockType) -> [[blockArea]] {
        switch blockType {
        case .I:
            return [[blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 0, column: 2)],
                    [blockArea(row: -1, column: 1), blockArea(row: 0, column: 1), blockArea(row: 1, column: 1), blockArea(row: -2, column: 1)],
                    [blockArea(row: -1, column: -1), blockArea(row: -1, column: 0), blockArea(row: -1, column: 1), blockArea(row: -1, column: 2)],
                    [blockArea(row: -1, column: 0), blockArea(row: 0, column: 0), blockArea(row: 1, column: 0), blockArea(row: -2, column: 0)]]
        case .O:
            return [[blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 1, column: 1), blockArea(row: 1, column: 0)]]
        case .T:
            return [[blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 1, column: 0)],
                    [blockArea(row: -1, column: 0), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 1, column: 0)],
                    [blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: -1, column: 0)],
                    [blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 1, column: 0), blockArea(row: -1, column: 0)]]
        case .J:
            return [[blockArea(row: 1, column: -1), blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1)],
                    [blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0), blockArea(row: 1, column: 1)],
                    [blockArea(row: -1, column: 1), blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1)],
                    [blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0), blockArea(row: -1, column: -1)]]
        case .L:
            return [[blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 1, column: 1)],
                    [blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0), blockArea(row: -1, column: 1)],
                    [blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: -1, column: -1)],
                    [blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0), blockArea(row: 1, column: -1)]]
        case .S:
            return [[blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: 1, column: 0), blockArea(row: 1, column: 1)],
                    [blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: -1, column: 1)],
                    [blockArea(row: 0, column: 1), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0), blockArea(row: -1, column: -1)],
                    [blockArea(row: 1, column: -1), blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0)]]
        case .Z:
            return [[blockArea(row: 1, column: -1), blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: 0, column: 1)],
                    [blockArea(row: 1, column: 1), blockArea(row: 0, column: 1), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0)],
                    [blockArea(row: 0, column: -1), blockArea(row: 0, column: 0), blockArea(row: -1, column: 0), blockArea(row: -1, column: 1)],
                    [blockArea(row: 1, column: 0), blockArea(row: 0, column: 0), blockArea(row: 0, column: -1), blockArea(row: -1, column: -1)]]
        }
    }
    
    func getKicks(clockwise: Bool) -> [blockArea] {
        return tetroBlock.getWallKicks(blockType: blockType, rotation: blockRotation, clockwise: clockwise)
    }
    
    //handles wall kicks to specify possible rotation if block is rotated against the side/wall of the game
    static func getWallKicks(blockType: BlockType, rotation: Int, clockwise: Bool) -> [blockArea] {
        let rotationCount = getAllBlocks(blockType: blockType).count
        
        var index = rotation % rotationCount
        if index < 0 { index += rotationCount }
        
        var wallKicks = getAllWallKicks(blockType: blockType)[index]
        if !clockwise {
            var counterKicks: [blockArea] = []
            for kick in wallKicks {
                counterKicks.append(blockArea(row: -1 * kick.row, column: -1 * kick.column))
            }
            wallKicks = counterKicks
        }
        return wallKicks
    }
    
    static func getAllWallKicks(blockType: BlockType) -> [[blockArea]] {
        switch blockType {
        case .O:
            return [[blockArea(row: 0, column: 0)]]
        case .I:
            return [[blockArea(row: 0, column: 0), blockArea(row: 0, column: -2), blockArea(row: 0, column: 1), blockArea(row: -1, column: -2), blockArea(row: 2, column: -1)],
                    [blockArea(row: 0, column: 0), blockArea(row: 0, column: -1), blockArea(row: 0, column: 2), blockArea(row: 2, column: -1), blockArea(row: -1, column: 2)],
                    [blockArea(row: 0, column: 0), blockArea(row: 0, column: 2), blockArea(row: 0, column: -1), blockArea(row: 1, column: 2), blockArea(row: -2, column: -1)],
                    [blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 0, column: -2), blockArea(row: -2, column: 1), blockArea(row: 1, column: -2)]
            ]
        case .J, .L, .S, .Z, .T:
            return [[blockArea(row: 0, column: 0), blockArea(row: 0, column: -1), blockArea(row: 1, column: -1), blockArea(row: 0, column: -2), blockArea(row: -2, column: -1)],
                    [blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: -1, column: 1), blockArea(row: 2, column: 0), blockArea(row: 1, column: 2)],
                    [blockArea(row: 0, column: 0), blockArea(row: 0, column: 1), blockArea(row: 1, column: 1), blockArea(row: -2, column: 0), blockArea(row: -2, column: 1)],
                    [blockArea(row: 0, column: 0), blockArea(row: 0, column: -1), blockArea(row: -1, column: -1), blockArea(row: 2, column: 0), blockArea(row: 2, column: -1)]
            ]
        }
    }
}

struct gameBlock {
    var blockType: BlockType
}

enum BlockType: CaseIterable {
    case I, T, O, J, L, S, Z
}

struct blockArea {
    var row: Int
    var column: Int
}
