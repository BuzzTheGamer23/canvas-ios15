//
//  CanvasBackgroundView.swift
//  Parent
//
//  Created by Brandon Pluim on 1/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import QuartzCore

public class TriangleBackgroundGradientView: UIImageView {
    var gradientLayer : CAGradientLayer = CAGradientLayer()

    var tintTopColor : UIColor = UIColor.clearColor()
    var tintBottomColor : UIColor = UIColor.clearColor()
    public var diagonal: Bool = true {
        didSet {
            updateTintColor()
        }
    }
    public var collection : UITraitCollection? {
        didSet {
            if let collection = collection {
                self.updateImage(collection)
            }
        }
    }

    public var tintOpacity : Float = 0.8 {
        didSet { updateTintColor() }
    }

    public init(frame: CGRect, tintTopColor: UIColor, tintBottomColor: UIColor) {
        self.tintTopColor = tintTopColor
        self.tintBottomColor = tintBottomColor

        super.init(frame: frame)

        commonInit()
        updateTintColor()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
        updateTintColor()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
        updateTintColor()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateTintColor()
    }

    func commonInit() {
        self.image = UIImage(named: "tri_pattern", inBundle: NSBundle(forClass: TriangleBackgroundGradientView.self), compatibleWithTraitCollection: collection)
        self.contentMode = .ScaleAspectFill
    }

    public func updateImage(collection: UITraitCollection, coordinator: UIViewControllerTransitionCoordinator? = nil) {
        self.image = UIImage(named: "tri_pattern", inBundle: NSBundle(forClass: TriangleBackgroundGradientView.self), compatibleWithTraitCollection: collection)
        let transition = CATransition()
        transition.duration = coordinator?.transitionDuration() ?? 1.0
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.layer.addAnimation(transition, forKey: nil)
    }

    public func transitionToColors(tintTopColor: UIColor, tintBottomColor: UIColor, duration: NSTimeInterval = 0.0) {

        gradientLayer.colors = [tintTopColor.CGColor, tintBottomColor.CGColor]

        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.fromValue = [self.tintTopColor.CGColor, self.tintBottomColor.CGColor]
        colorAnimation.toValue = [tintTopColor.CGColor, tintBottomColor.CGColor]
        colorAnimation.duration = duration
        gradientLayer.addAnimation(colorAnimation, forKey: "colorAnimation")

        self.tintTopColor = tintTopColor
        self.tintBottomColor = tintBottomColor
    }

    func updateTintColor() {
        gradientLayer.frame = bounds
        gradientLayer.opacity = tintOpacity
        gradientLayer.removeFromSuperlayer()
        gradientLayer.colors = [tintTopColor.CGColor, tintBottomColor.CGColor]

        if diagonal {
            gradientLayer.startPoint = CGPointMake(0.0, 1)
            gradientLayer.endPoint = CGPointMake(1.0, 0.0)
        } else {
            gradientLayer.startPoint = CGPointMake(0.5, 1)
            gradientLayer.endPoint = CGPointMake(0.5, 0)
        }
        
        layer.addSublayer(gradientLayer)
    }
    
}