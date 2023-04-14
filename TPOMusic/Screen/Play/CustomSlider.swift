//
//  CustomSlider.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/04/14.
//

import UIKit


class CustomSlider: UISlider {

@IBInspectable var trackHeight: CGFloat = 6

    lazy var defaultThumbSpace: Float = Float(UIScreen.main.bounds.width / 55.714)
       lazy var startingOffset: Float = 0 + defaultThumbSpace
       lazy var endingOffset: Float = -2 * defaultThumbSpace


    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = trackHeight
        rect.origin.y -= trackHeight / 2

        return rect
      }
    

    override func layoutSubviews() {
        super.layoutSubviews()

        if let layers = layer.sublayers?.first?.sublayers, layers.count > 0 {
            layers[1].cornerRadius = layers[1].bounds.height / 2
        }
    }


 //avplayer로 실행시 에러?
       override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
           print(value)
           let xTranslation: Float
           if maximumValue != 0.0 {
            xTranslation =  startingOffset + (minimumValue + endingOffset) / maximumValue * value
           } else {
               xTranslation = 0.0
           }

           var newRect = super.thumbRect(forBounds: bounds,
                                  trackRect: rect.applying(CGAffineTransform(translationX: CGFloat(xTranslation),
                                                                             y: 0)),
                                  value: value)
           newRect.size.width = 0.01
           return newRect
       }
}
