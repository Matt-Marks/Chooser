//
//  UICustomSelectionButton.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 6/13/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit

class ThemeButton: UIControl {
    
    // MARK: - Constants & Variables
    
    /// The top color on of the gradient.
    public var topColor: UIColor = .white {
        didSet { setGradient(topColor, bottomColor) }
    }
    
    /// The bottom color of the gradient.
    public var bottomColor: UIColor = .black {
        didSet { setGradient(topColor, bottomColor) }
    }
    
    /// The CAGradientLayer responsible for the presentation of the gradient.
    private var gradientLayer = CAGradientLayer()
    
    /// If the theme is chosen, this is true. Otherwise, false.
    private var isChosen: Bool = false
    
    private enum Constants {
        static let cornerRadius: CGFloat          = 8.0
        static let rotationAngle: CGFloat         =  -.pi/20
        static var borderWidth: CGFloat           = 2.0
        static let selectedBorderColor: CGColor   = UIColor.white.cgColor
        static let unselectedBorderColor: CGColor = UIColor.clear.cgColor
        static let subtleBorderColor: CGColor     = UIColor.init(hexVal: 0xC6C7CB).cgColor
        static let subtleBorderWidth: CGFloat     = 0.4
    }
    
    // MARK: - Public Functions
    
    /// Updates the 'chosen' state of the button.
    /// A check mark appears or disappears accordingly. 
    ///
    /// - Parameters:
    ///     - newVal: A Boolean representing the new chosen state.
    ///     - animated: A Boolean representing if the check mark should animate or not.
    public func setChosen(_ newVal: Bool, animated: Bool) {
        if !isChosen && newVal {
            layer.borderColor = Constants.selectedBorderColor
        } else if isChosen && !newVal {
            layer.borderColor = Constants.unselectedBorderColor
        }
        isChosen = newVal
    }
    

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        configureSelf()
        configureGradientLayer()
    }
    

    // MARK: - Configuration
    
    /// Sets up the shape, rotation, and border of the button itself.
    private func configureSelf() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = isChosen ? Constants.selectedBorderColor : Constants.unselectedBorderColor
        transform = CGAffineTransform.init(rotationAngle: Constants.rotationAngle)
    }
    
    /// Sets up the shape, rotation, and border of the gradient icon card
    /// inside the button.
    private func configureGradientLayer() {
        gradientLayer.frame = bounds.insetBy(dx: Constants.borderWidth, dy: Constants.borderWidth)
        gradientLayer.cornerRadius = Constants.cornerRadius - Constants.borderWidth
        gradientLayer.borderWidth = Constants.subtleBorderWidth
        gradientLayer.borderColor = Constants.subtleBorderColor
        layer.addSublayer(gradientLayer)
        setGradient(topColor, bottomColor)
    }
    
    /// Updates the gradient colors of the button.
    ///
    /// - Parameters:
    ///     - topColor: A UIColor representing the top color of the gradient.
    ///     - bottomColor: A UIColor representing the bottom color of the gradient.
    private func setGradient(_ topColor: UIColor, _ bottomColor: UIColor) {
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
    }
    

    // MARK: - Touch Event Handling
    
    /// Called when the users finger is placed on the button.
    /// Then button is animated to be smaller.
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        performTouchDownAnimation()
        return true
    }
    
    /// Called when the users finger is moving on the screen.
    /// If the user drage their finger off the button the button is automatically
    /// deselected.
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        if !bounds.contains(touch.location(in: self)) {
            performTouchUpAnimation()
        }
        return true
    }
    
    /// Called when the user lifts their finger form the button.
    /// The button is only selected if the user's fimnger is still within the
    /// buttons frame.
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        performTouchUpAnimation()
    }
    
    /// Called when the touch event is interrupted. This can occur when a phone call
    /// comes, or two many fingers are placed on the screen, etc. The button is animated
    /// back to normal and not selected.
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        performTouchUpAnimation()
    }
    

    // MARK: - Animations
    
    /// Called when the users finger is pressed down on the button.
    /// The button's scale is animated to shrink to a smaller size.
    private func performTouchDownAnimation() {
        var t = CGAffineTransform.identity
        t = t.scaledBy(x: 0.8, y: 0.8)
        t = t.rotated(by: Constants.rotationAngle)
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                       animations: {
                        self.transform = t
        })
    }
    
    /// Called when the users finger is released from the button.
    /// A slight spring animation pops the button back to its original size.
    private func performTouchUpAnimation() {
        let t = CGAffineTransform.init(rotationAngle: Constants.rotationAngle)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction], animations: {
                        self.transform = t
        }, completion: nil)
    }
    
}
