//
//  UIView+Ex.swift
//  StarFall
//
//  Created by wangwenjian on 2023/8/10.
//

import Foundation
import UIKit

extension String {
    
    var image: UIImage {
        return UIImage(named: self) ?? UIImage(named: "outline_help_outline_black_36pt_")!
    }
    
    var local: String {
        return NSLocalizedString(self, comment: self)
    }
}

extension Int {
    
    var font: UIFont {
        return UIFont.systemFont(ofSize: CGFloat(self))
    }
    
    var fontHeavy: UIFont {
        return UIFont.systemFont(ofSize: CGFloat(self), weight: .heavy)
    }
    
    var fontBold: UIFont {
        return UIFont.systemFont(ofSize: CGFloat(self), weight: .bold)
    }
    
    var fontMedium: UIFont {
        return UIFont.systemFont(ofSize: CGFloat(self), weight: .medium)
    }
    
    var rgbColor: UIColor {
        let r = CGFloat((self & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((self & 0xFF00) >> 8) / 255.0
        let b = CGFloat(self & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension UILabel {
    func style(_ font: UIFont, textColor: UIColor) {
        self.font = font
        self.textColor = textColor
    }
    
    func styleLargeNum() {
        style(18.fontBold, textColor: 0x222222.rgbColor)
    }
}

extension UIColor {
    
    class func mixColors(color1: UIColor, color2: UIColor, ratio1: CGFloat, ratio2: CGFloat) -> UIColor? {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        // 获取第一种颜色的RGB值和透明度
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        // 获取第二种颜色的RGB值和透明度
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        // 计算新的RGB值
        let newRed = (r1 * ratio1 + r2 * ratio2) / (ratio1 + ratio2)
        let newGreen = (g1 * ratio1 + g2 * ratio2) / (ratio1 + ratio2)
        let newBlue = (b1 * ratio1 + b2 * ratio2) / (ratio1 + ratio2)
        
        // 创建新的颜色对象并返回
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}
