//
//  UIToggleButton.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 5/29/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit

class CustomSwitch: UIControl {
    
    // MARK: - Constants & Variables
    
    /// The current state of the switch.
    public var isOn: Bool = true {
        didSet { animate(fromState: !isOn, toState: isOn) }
    }
    
    /// The layer that contains a pill-shaped path with a cutout for the thumb.
    private let fillShape: CAShapeLayer
    
    /// The layer that contains a circular path representing the thumb.
    private let thumbShape: CAShapeLayer
    
    private enum Constants {
        static let accentColor: UIColor = .white
        static let animationDuration: TimeInterval = 0.25
        static let padding: CGFloat = 5.0
        static let borderWidth: CGFloat = 1.0
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        fillShape = CAShapeLayer()
        thumbShape = CAShapeLayer()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fillShape = CAShapeLayer()
        thumbShape = CAShapeLayer()
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderColor  = Constants.accentColor.cgColor
        layer.borderWidth  = Constants.borderWidth
        layer.cornerRadius = bounds.midY
        
        fillShape.path  = getFilledPath(state: isOn).cgPath
        fillShape.frame = bounds
        layer.addSublayer(fillShape)
        
        thumbShape.path  = getThumbPath(state: isOn).cgPath
        thumbShape.frame = bounds
        layer.addSublayer(thumbShape)
        
        updateFillColors()
    }
    
    /// Called in both the 'layoutSubviews' method and whenever the 'detailColor' variable
    /// is updated. This changes the color of the switch to the new detailColor.
    private func updateFillColors() {
        fillShape.fillColor  = isOn ? Constants.accentColor.cgColor : UIColor.clear.cgColor
        thumbShape.fillColor = isOn ? UIColor.clear.cgColor : Constants.accentColor.cgColor
    }
    
    
    /// Called whent the user touches the switch. An action is sent to the target letting
    /// it know the value has changed, a slight haptic impact is generated, and the
    /// switch is toggled to the inverse of its current state.
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        sendActions(for: .valueChanged)
        if UserPreferences.vibrations {
            UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
        }
        isOn.toggle()
        return true
    }
    
    /// Gives a circular path representing the thumb. The circle is to the left for the
    /// off state and to the right for the on state.
    ///
    /// - Parameters:
    ///     - state: A boolean representing if the circle should be left or right.
    ///
    /// - Returns:
    ///     A UIBezierPath in the shape of a circle that is either on the left hand
    ///     size or the right hand side.
    private func getThumbPath(state: Bool) -> UIBezierPath {
        let thumbDiameter = bounds.height - (2 * Constants.padding)
        let xOrigin       = state ? bounds.width - thumbDiameter - Constants.padding : Constants.padding
        let origin        = CGPoint(x: xOrigin, y: Constants.padding)
        let size          = CGSize(width: thumbDiameter, height: thumbDiameter)
        return UIBezierPath(ovalIn: CGRect(origin: origin, size: size))
    }
    
    /// Gives a pill shaped path with a circular cutout representing the thumb.
    /// The circular cutout is to the left for the off state and to the right for
    /// the on state.
    ///
    /// - Parameters:
    ///     - state: A boolean representing if the circle should be left or right.
    ///
    /// - Returns:
    ///     A UIBezierPath in the shape of a pill with a circle cutout that is
    ///     either on the left hand side or the right hand side.
    private func getFilledPath(state: Bool) -> UIBezierPath {
        let cornerRadii = CGSize(width: bounds.midY, height: bounds.midY)
        let pillPath    = UIBezierPath(roundedRect: bounds,
                                       byRoundingCorners: .allCorners,
                                       cornerRadii: cornerRadii)
        pillPath.append(getThumbPath(state: state).reversing())
        return pillPath
    }
    
    // MARK: - Animations
    
    /// This is called when the 'isOn' boolean changes value. An animation is performed
    /// that chananges the switch from on to off. The animation consists of 4 animations
    /// occuring simultaneously. First, we animate the fill layer (that has a cutout of
    /// the thumb) moving the thumb cutout from left to right or vice versa. Second, we
    /// animate the fill color of that fill layer; in the on state the fill color is the
    /// detail color and in the off state that color is clear. Third we animate the
    /// circular path representing the thumb from left to right of vice versa. Finally,
    /// we animate the fill color of that thumb shape; in the on state the fill color of
    /// the thumb is clear, and in the off state the fill color of the thumb is the
    /// detail color. These 4 animations create the effect of inverting the color of the
    /// switch every time it is turned on and off.
    ///
    /// - Parameteres:
    ///     - fromState: A boolean representing the previous 'isOn' state of the switch.
    ///     - toState: A boolean representing the new 'isOn' state of the switch.
    private func animate(fromState: Bool, toState: Bool) {
        
        // Animates fill layer's circle cut out position.
        animateLayerPath(layer: fillShape,
                         fromPath: getFilledPath(state: fromState).cgPath,
                         toPath: getFilledPath(state: toState).cgPath)
        
        // Animates fill layer's fill color.
        animateLayerColor(layer: fillShape,
                          fromColor: fromState ? .clear : Constants.accentColor,
                          toColor: toState ? Constants.accentColor : .clear)
        
        // Animates thumb layer's circle position.
        animateLayerPath(layer: thumbShape,
                         fromPath: getThumbPath(state: fromState).cgPath,
                         toPath: getThumbPath(state: toState).cgPath)
        
        // Animates thumb layer's circle fill color.
        animateLayerColor(layer: thumbShape,
                          fromColor: fromState ? Constants.accentColor : .clear,
                          toColor: toState ? .clear : Constants.accentColor)
    }
    
    /// This takes the given CAShapeLayer and applies a CABasicAnimation to
    /// change its path.
    ///
    /// - Parameters:
    ///     - layer: The CAShapeLayer whose path will be animated.
    ///     - fromPath: The path the animation will start with.
    ///     - toPath: The path the animation will end on. This will be the new path
    ///                of the CAShapeLayer
    private func animateLayerPath(layer: CAShapeLayer,
                                  fromPath: CGPath,
                                  toPath: CGPath) {
        let animation            = CABasicAnimation()
        animation.keyPath        = "path"
        animation.duration       = Constants.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue      = fromPath
        animation.toValue        = toPath
        layer.add(animation, forKey: "path")
        layer.path               = toPath
    }
    
    /// This takes the given CAShapeLayer and applies a CABasicAnimation to
    /// change its fill color.
    ///
    /// - Parameters:
    ///     - layer: The CAShapeLayer whose fill will be animated.
    ///     - fromColor: The color the animation will start with.
    ///     - toColor: The color the animation will end on. This will be the new fill
    ///                of the CAShapeLayer
    private func animateLayerColor(layer: CAShapeLayer,
                                   fromColor: UIColor,
                                   toColor: UIColor) {
        let animation            = CABasicAnimation()
        animation.keyPath        = "fillColor"
        animation.duration       = Constants.animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue      = fromColor.cgColor
        animation.toValue        = toColor.cgColor
        layer.add(animation, forKey: "fillColor")
        layer.fillColor          = toColor.cgColor
    }

    
    
    
    
    
}
