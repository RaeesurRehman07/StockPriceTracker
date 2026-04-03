//
//  UIView+Extension.swift
//  StockPriceTracker
//
//  Created by Raees Ur rehman on 03/04/2026.
//

import Foundation
import UIKit

extension UIView {
    
    func applyShadow(
        color: UIColor = .black,
        opacity: Float = 0.3,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 4,
        cornerRadius: CGFloat = 0,
        useShadowPath: Bool = true
    ) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        
        if cornerRadius > 0 {
            layer.cornerRadius = cornerRadius
        }
        
        // 🚀 Performance optimization
        if useShadowPath {
            layer.shadowPath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: cornerRadius
            ).cgPath
        }
    }
}
