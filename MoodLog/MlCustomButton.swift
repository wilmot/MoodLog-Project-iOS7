//
//  MlCustomButton.swift
//  Mood-Log
//
//  Created by Barry Langdon-Lassagne on 4/17/17.
//  Copyright © 2017 Barry Langdon-Lassagne. All rights reserved.
//

import UIKit

@IBDesignable class MlCustomButton: UIButton {
    @IBInspectable var lineColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    @IBInspectable var tapColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    fileprivate var _fillColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    @IBInspectable var fillColor: UIColor {
        get {
            return _fillColor
        }
        set(newValue) {
            _fillColor = newValue
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var lineWidth: CGFloat = 0.5
    @IBInspectable var inset: CGFloat = 10.0
    @IBInspectable var cornerRadius: CGFloat = 20.0
    @IBInspectable var centerOffsetX: CGFloat = 0.0
    @IBInspectable var centerOffsetY: CGFloat = 0.0
    @IBInspectable var image: UIImage? = nil
    @IBInspectable var subTitle: String = ""
    @IBInspectable var subTitleTextColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    @IBInspectable var subTitleXOffset: CGFloat = 0.0
    @IBInspectable var subTitleYOffset: CGFloat = 0.0
    
    func click() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = CGPoint(x: frame.midX, y: frame.midY)
        layer.addSublayer(rectShape)
        rectShape.lineWidth = 6.0
        rectShape.strokeColor = tapColor.darker(by: 5).cgColor
        rectShape.fillColor = UIColor.clear.cgColor

        let startShape = UIBezierPath(ovalIn: CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)).cgPath
        let endShape   = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)).cgPath
        
        // set initial shape
        rectShape.path = startShape
        
        // animate the `path`
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = endShape
        animation.duration = 0.25
        
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        animation.fillMode = CAMediaTimingFillMode.both // keep to value after finishing
        animation.isRemovedOnCompletion = true // don't remove after finishing

        rectShape.add(animation, forKey: animation.keyPath)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: inset, dy: inset), cornerRadius: cornerRadius)

        fillColor.set()
        path.fill()
        lineColor.set()
        path.lineWidth = lineWidth
        path.stroke()

        lineColor.set() // TODO: allow image color to be custom
        let spot = rect.center()
        if let image = image {
            let height = image.size.height
            let width = image.size.width
            image.draw(at: CGPoint(x: spot.x + centerOffsetX - width/2, y: spot.y + centerOffsetY - height/2))
        }
        
        let title = NSAttributedString(string: subTitle,
                    attributes: [NSAttributedString.Key.foregroundColor: subTitleTextColor,
                                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        let size = title.size()
        title.draw(at: CGPoint(x: spot.x + subTitleXOffset - size.width/2, y: rect.maxY - size.height - 14.0 + subTitleYOffset))
    }
}


