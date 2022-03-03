//
//  TetrisView.swift
//  TetrisGame
//
//  Created by Nihal Syed on 2021-04-11.
//

import SwiftUI

struct TetrisView: View {
    @ObservedObject var tetrisGame = TetrisViewModel()
    
    var body: some View {
        //draws gameboard for swift UI view
        GeometryReader { (geometry: GeometryProxy) in
            self.drawGameBoard(boundingRect: geometry.size)
        }
        .gesture(tetrisGame.moveGesture())
        .gesture(tetrisGame.rotateGesture())
    }
    
    //fucntion to draw game board based on row and col initialized 
    func drawGameBoard(boundingRect: CGSize) -> some View {
        let col = self.tetrisGame.numCols
        let row = self.tetrisGame.numRows
        let gameBoard = self.tetrisGame.gameBoard
        let blocksize = min(boundingRect.width/CGFloat(col), boundingRect.height/CGFloat(row))
        let offsetOfYPoint = (boundingRect.height - blocksize*CGFloat(row))/2
        let offsetOfXPoint = (boundingRect.width - blocksize*CGFloat(col))/2

        
        return ForEach(0...col-1, id:\.self) { (col:Int) in
            ForEach(0...row-1, id:\.self) { (row:Int) in
                Path { path in
                    let x = offsetOfXPoint + blocksize * CGFloat(col)
                    let y = boundingRect.height - offsetOfYPoint - blocksize*CGFloat(row+1)
                    let rect = CGRect(x: x, y: y, width: blocksize, height: blocksize)
                    path.addRect(rect)
                }
                .fill(gameBoard[col][row].color)
            }
        }
    }
}

struct TetrisView_Previews: PreviewProvider {
    static var previews: some View {
        TetrisView()
    }
}

