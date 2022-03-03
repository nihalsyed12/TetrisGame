//
//  TetrisViewModel.swift
//  TetrisGame
//
//  Created by Nihal Syed on 2021-04-11.
//

import SwiftUI
import Combine

class TetrisViewModel: ObservableObject {
    @Published var gameModel = TetrisModel()
    var locLastMove: CGPoint?
    var lastRotateAngle: Angle?
    var anyCancellable: AnyCancellable?
    var numRows: Int { gameModel.numRow }
    var numCols: Int { gameModel.numCol }
    //maps array for gameboard and handles game blocks as well as the phantom block
    var gameBoard: [[blockSquare]] {
        var gboard = gameModel.gboard.map { $0.map(makeSquare) }
        
        if let tetrisGameBlock = gameModel.tetrisBlock {
            for blockLocation in tetrisGameBlock.blocks {
                gboard[blockLocation.column + tetrisGameBlock.blockOrigin.column][blockLocation.row + tetrisGameBlock.blockOrigin.row] = blockSquare(color: getColor(blockType: tetrisGameBlock.blockType))
            }
        }
        
        if let shade = gameModel.shade {
            for blockLocation in shade.blocks {
                gboard[blockLocation.column + shade.blockOrigin.column][blockLocation.row + shade.blockOrigin.row] = blockSquare(color: getShadeColor(blockType: shade.blockType))
            }
        }
        
        
        return gboard
    }
    
    init() {
        anyCancellable = gameModel.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    
    func makeSquare(block: gameBlock?) -> blockSquare {
        return blockSquare(color: getColor(blockType: block?.blockType))
    }
    
    func moveGesture() -> some Gesture {
        return DragGesture()
        .onChanged(moveChanged(value:))
        .onEnded(movedEnded(_:))
    }
    
    
    func moveChanged(value: DragGesture.Value) {
        guard let startMove = locLastMove else {
            locLastMove = value.location
            return
        }
        let diffOfYPoint = value.location.y - startMove.y
        if diffOfYPoint > 10 {
            print("Block Moving Down")
            let _ = gameModel.blockMoveD()
            locLastMove = value.location
            return
        }
        if diffOfYPoint < -10 {
            print("Block Dropping")
            gameModel.blockFall()
            locLastMove = value.location
            return
        }
        
        let diffOfXPoint = value.location.x - startMove.x
        if diffOfXPoint > 10 {
            print("Block Moving right")
            let _ = gameModel.blockMoveR()
            locLastMove = value.location
            return
        }
        if diffOfXPoint < -10 {
            print("Block Moving left")
            let _ = gameModel.blockMoveL()
            locLastMove = value.location
            return
        }
    }
    
    func rotateChanged(value: RotationGesture.Value) {
        guard let startRotate = lastRotateAngle else {
            lastRotateAngle = value
            return
        }
        
        let rotateDifference = value - startRotate
        if rotateDifference.degrees > 10 {
            gameModel.blockRotation(clockwise: true)
            lastRotateAngle = value
            return
        } else if rotateDifference.degrees < -10 {
            gameModel.blockRotation(clockwise: false)
            lastRotateAngle = value
            return
        }
    }
    
    func rotateGesture() -> some Gesture {
        let tap = TapGesture()
            .onEnded({self.gameModel.blockRotation(clockwise: true)})
        
        let rotate = RotationGesture()
            .onChanged(rotateChanged(value:))
            .onEnded(rotateEnded(value:))
        
        return tap.simultaneously(with: rotate)
    }
    
    func rotateEnded(value: RotationGesture.Value) {
        lastRotateAngle = nil
    }
    
    func movedEnded(_: DragGesture.Value) {
        locLastMove = nil
    }
    
    //sets block color for each block case 
    func getColor(blockType: BlockType?) -> Color {
        switch blockType {
        case .I:
            return .blockDenimBlue
        case .J:
            return .blockOrchidPink
        case .L:
            return .blockHunterGreen
        case .O:
            return .blockNaplesYellow
        case .S:
            return .blockBittersweetPink
        case .T:
            return .blockMediumTurquoise
        case .Z:
            return .blockYCinnabarRed
        case .none:
            return .blockBackground
        }
    }
    
    //sets shaded block color for each block case
    func getShadeColor(blockType: BlockType) -> Color {
        switch blockType {
        case .I:
            return .blockDenimBlueShade
        case .J:
            return .blockOrchidPinkShade
        case .L:
            return .blockHunterGreenShade
        case .O:
            return .blockYellowLightShade
        case .S:
            return .blockBittersweetPinkShade
        case .T:
            return .blockMediumTurquoiseShade
        case .Z:
            return .blockCinnabarRedShade
        }
    }
}

//struct for gameblock that sets color
struct blockSquare {
    var color: Color
}
