//
//  Figure.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

enum FigureType {
    case pawn, rook, knight, bishop, queen, king
}

enum FigureColor {
    case white, black
}

class FigurePosition {
    var x:CGFloat
    var y:CGFloat
    
    init(x:CGFloat, y:CGFloat) {
        self.x = x
        self.y = y
    }
}

class Figure: UIImageView {

    var type:FigureType?
    var color:FigureColor?
    var position:FigurePosition?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(_ type:FigureType, color:FigureColor, position:FigurePosition) {
        switch type {
        case .pawn:
            switch color {
            case .white:
                super.init(image: UIImage(named: "wPawn"))
            case .black:
                super.init(image: UIImage(named: "bPawn"))
            }
        case .rook:
            switch color {
            case .white:
                super.init(image: UIImage(named: "wRook"))
            case .black:
                super.init(image: UIImage(named: "bRook"))
            }
        case .knight:
            switch color {
            case .white:
                super.init(image: UIImage(named: "wKnight"))
            case .black:
                super.init(image: UIImage(named: "bKnight"))
            }
        case .bishop:
            switch color {
            case .white:
                super.init(image: UIImage(named: "wBishop"))
            case .black:
                super.init(image: UIImage(named: "bBishop"))
            }
        case .queen:
            switch color {
            case .white:
                super.init(image: UIImage(named: "wQueen"))
            case .black:
                super.init(image: UIImage(named: "bQueen"))
            }
        case .king:
            switch color {
            case .white:
                super.init(image: UIImage(named: "wKing"))
            case .black:
                super.init(image: UIImage(named: "bKing"))
            }
        }
        
        self.type = type
        self.color = color
        self.position = position
    }
    
}
