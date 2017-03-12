//
//  Desk.swift
//  v-Chess
//
//  Created by Сергей Сейтов on 12.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

import UIKit

class Desk: UIImageView {

    var figures:[Figure] = []
    var rotated = false {
        didSet {
            setNeedsLayout()
        }
    }
  
    override func awakeFromNib() {
        super.awakeFromNib()
        for i in 0...7 {
            let w = Figure(.pawn, color: .white, position: FigurePosition(x: CGFloat(i), y: CGFloat(1)))
            figures.append(w)
            let b = Figure(.pawn, color: .black, position: FigurePosition(x: CGFloat(i), y: CGFloat(6)))
            figures.append(b)
            addSubview(w)
            addSubview(b)
        }
        var f = Figure(.rook, color: .white, position: FigurePosition(x: CGFloat(0), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.knight, color: .white, position: FigurePosition(x: CGFloat(1), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.bishop, color: .white, position: FigurePosition(x: CGFloat(2), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.queen, color: .white, position: FigurePosition(x: CGFloat(3), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.king, color: .white, position: FigurePosition(x: CGFloat(4), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.bishop, color: .white, position: FigurePosition(x: CGFloat(5), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.knight, color: .white, position: FigurePosition(x: CGFloat(6), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        f = Figure(.rook, color: .white, position: FigurePosition(x: CGFloat(7), y: CGFloat(0)))
        figures.append(f)
        addSubview(f)
        
        f = Figure(.rook, color: .black, position: FigurePosition(x: CGFloat(0), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.knight, color: .black, position: FigurePosition(x: CGFloat(1), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.bishop, color: .black, position: FigurePosition(x: CGFloat(2), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.queen, color: .black, position: FigurePosition(x: CGFloat(3), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.king, color: .black, position: FigurePosition(x: CGFloat(4), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.bishop, color: .black, position: FigurePosition(x: CGFloat(5), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.knight, color: .black, position: FigurePosition(x: CGFloat(6), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
        f = Figure(.rook, color: .black, position: FigurePosition(x: CGFloat(7), y: CGFloat(7)))
        figures.append(f)
        addSubview(f)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let stepX = frame.size.width/8
        let stepY = frame.size.height/8
        if rotated {
            for figure in figures {
                figure.frame = CGRect(x: figure.position!.x*stepX, y: figure.position!.y*stepY, width: stepX, height: stepY)
            }
        } else {
            for figure in figures {
                figure.frame = CGRect(x: figure.position!.x*stepX, y: (7 - figure.position!.y)*stepY, width: stepX, height: stepY)
            }
        }
    }
}
