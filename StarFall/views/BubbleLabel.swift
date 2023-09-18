//
//  BubbleLabel.swift
//  StarFall
//
//  Created by wangwenjian on 2023/8/17.
//

import Foundation
import UIKit

class BubbleLabel: UILabel {
    
    enum Direction {
        case top
        case left
        case right
        case bottom
    }
    
    var paddingV: CGFloat = 5
    var paddingH: CGFloat = 8
    
    var arrowSize: CGFloat = 10
    
    var direction: Direction = .bottom
    
    var textInserts: UIEdgeInsets {
        var inserts = UIEdgeInsets(top: paddingV, left: paddingH, bottom: paddingV, right: paddingH)
        switch direction {
        case .top:
            inserts.top += arrowSize
        case .right:
            inserts.right += arrowSize
        case .left:
            inserts.left += arrowSize
        case .bottom:
            inserts.bottom += arrowSize
        }
        return inserts
    }
    
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let inserts = textInserts
        var rect = super.textRect(forBounds: bounds.inset(by: inserts), limitedToNumberOfLines: numberOfLines)
        rect.size.width += (inserts.left + inserts.right)
        rect.size.height += (inserts.top + inserts.bottom)
        return rect
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInserts))
        
        addbounds(in: rect)
    }
    
    func addbounds(in rect: CGRect){
        let path = UIBezierPath()
        path.move(to: CGPoint(x: paddingH, y: 0))
        path.addLine(to: CGPoint(x: rect.width - paddingH * 2, y:0))
        path.addArc(withCenter: CGPoint(x: rect.width - paddingH * 2, y: (rect.height - arrowSize)/2 ), radius: (rect.height - arrowSize)/2, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi/2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.width/2 + arrowSize/2, y: rect.height - arrowSize))
        path.addLine(to: CGPoint(x: rect.width/2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width/2 - arrowSize/2, y: rect.height - arrowSize))
        path.addLine(to: CGPoint(x: rect.width - paddingH * 2, y: rect.height - arrowSize))
        path.addArc(withCenter: CGPoint(x: paddingH * 2, y: (rect.height - arrowSize)/2 ), radius: (rect.height - arrowSize)/2, startAngle: CGFloat.pi/2, endAngle: -CGFloat.pi/2, clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        self.layer.mask = shapeLayer
    }
}
