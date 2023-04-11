//
//  SliderView.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

@IBDesignable open class SliderView: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 5
    @IBInspectable var minColor: UIColor? { didSet {
        setMinimumTrackImage(getImageWithColor(color: minColor, height: trackHeight), for: .normal)
        setThumbImage(getThumbWithColor(color: minColor, height: trackHeight), for: .normal)
    } }
    @IBInspectable var minHLColor: UIColor? { didSet {
        setMinimumTrackImage(getImageWithColor(color: minHLColor, height: trackHeight), for: .highlighted)
        setThumbImage(getThumbWithColor(color: minHLColor, height: trackHeight), for: .highlighted)
    } }
    @IBInspectable var maxColor: UIColor? { didSet {setMaximumTrackImage(getImageWithColor(color: maxColor, height: trackHeight), for: .normal) } }
    @IBInspectable var maxHLColor: UIColor? { didSet { setMaximumTrackImage(getImageWithColor(color: maxHLColor, height: trackHeight), for: .highlighted) } }
    
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        handleTap(touch)
        return true
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        //set your bounds here
        let y0 = (bounds.height-trackHeight) / 2
        let origin = CGPoint(x: bounds.origin.x, y: y0)
        return CGRect(origin: origin, size: CGSize(width: bounds.width, height: trackHeight))
    }
    
    func getImageWithColor(color: UIColor? = .black, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: height)
        let size = CGSize(width: 1, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color?.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func getThumbWithColor(color: UIColor? = .black, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: height/2, height: height)
        let size = CGSize(width: height/2, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color?.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc private func handleTap(_ sender: UITouch) {
        let location = sender.location(in: self)
        let percent = minimumValue + Float(location.x / bounds.width) * maximumValue
        setValue(percent, animated: true)
        sendActions(for: .valueChanged)
    }
    
}
