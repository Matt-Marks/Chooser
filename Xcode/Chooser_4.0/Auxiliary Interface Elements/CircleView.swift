//
//  UICircle.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 3/14/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    // MARK: - Constants & Variables
    
    /// The controller that holds this circle.
    /// The declaration of the UICircleDelegate protocol can be found at the bottom of this file.
    public var delegate: UICircleDelegate!
    
    /// The color this circle will be.
    private var color: UIColor!
    
    /// We use a fill layer to fill the circle during pulses and winning.
    private var fillLayer = CAShapeLayer()
    
    /// A boolean so this circle knows if it is a winner or not.
    public var isWinner = false
    
    private enum Constants {
        static let opacityKeyPath: String   = "opacity"
        static let fillColorKeyPath: String = "fillColor"
        static let scaleKeyPath: String     = "transform.scale"
        static let zRotationKeyPath: String = "transform.rotation.z"
        static let exitKey: String          = "exit"
        static let borderColorKey: String   = "borderColor"
        static let emitterImageName: String = "Emitter Contents"
        
        static let radius: CGFloat          = 65
        static let thickness: CGFloat       = 14
        static let shadowColor: CGColor     = UIColor.black.cgColor
        static let shadowOffset: CGSize     = .zero
        static let shadowRadius: CGFloat    = 10.0
        static let shadowOpacity: Float     = 0.1
    }
    
    // MARK: - Initialization
    
    /// Each circle is initialized with a color. The border of the circle
    /// becomes that color. Upon winning, the center of that circle also becomes
    /// that color.
    convenience init(color: UIColor) {
        self.init()
        self.color = color
        configureBorder()
        configureMorphology()
        configureShadow()
        configureFillLayer()
    }
    
    // MARK: - Configuration
    
    /// Sets this view's size and makes it a circle.
    private func configureMorphology() {
        frame.size = CGSize(width: 2 * Constants.radius,
                            height: 2 * Constants.radius)
        layer.cornerRadius = Constants.radius
    }
    
    /// Sets circles views border to the correct thickness and color.
    private func configureBorder() {
        layer.borderWidth = Constants.thickness
        layer.borderColor = color.cgColor
    }
    
    /// Each circle has a slight shadow. It looks nice. Shadows are in style.
    private func configureShadow() {
        layer.shadowColor   = Constants.shadowColor
        layer.shadowOffset  = Constants.shadowOffset
        layer.shadowRadius  = Constants.shadowRadius
        layer.shadowOpacity = Constants.shadowOpacity
    }

    /// When a circle pulses, or when it is chosen as a winner, its fill color is
    /// changed to match its border color. However, winning circles also have
    /// emitter layers. This means that we can't just change the background color
    /// of the circle because then the emitted particles will appear over it. We
    /// need to change the circles color by changing the color of a fill layer
    /// placed inside the circle. This function puts a clear fill layer in
    /// the circle. */
    private func configureFillLayer() {
        fillLayer.path = UIBezierPath(arcCenter: CGPoint(x: Constants.radius, y: Constants.radius),
                                      radius: Constants.radius,
                                      startAngle: 0,
                                      endAngle: 2 * .pi,
                                      clockwise: true).cgPath
        
        fillLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(fillLayer)
        layer.insertSublayer(fillLayer, at: 1)
    }
    

    // MARK: - Animations
    
    /// When a circle is created it grows to fill size with a spring animation.
    public func animateEntrance() {
        let scale                   = CASpringAnimation()
        scale.keyPath               = Constants.scaleKeyPath
        scale.fromValue             = 0.3
        scale.toValue               = 1.0
        scale.damping               = 6.0
        scale.initialVelocity       = 3.1
        scale.duration              = 1.5
        scale.timingFunction        = CAMediaTimingFunction(name: .default)
        scale.isRemovedOnCompletion = false
        transform = .identity
        layer.add(scale, forKey: nil)
    }
    
    /// When a circle is removed from the screen it shrinks and fades away at the same time.
    public func animateExit() {
        let scale                   = CABasicAnimation()
        scale.keyPath               = Constants.scaleKeyPath
        scale.fromValue             = currentScale()
        scale.toValue               = 0.01
        scale.duration              = 0.2
        scale.timingFunction        = CAMediaTimingFunction(name: .default)
        scale.isRemovedOnCompletion = false
        scale.delegate              = self
        transform                   = CGAffineTransform(scaleX: 0.01, y: 0.01)
        layer.add(scale, forKey: Constants.exitKey)
        
        let fade       = CABasicAnimation()
        fade.keyPath   = Constants.opacityKeyPath
        fade.fromValue = currentOpacity()
        fade.toValue   = 0.0
        fade.duration  = 0.2
        fade.fillMode  = CAMediaTimingFillMode.forwards
        alpha          = 0.0
        layer.add(fade, forKey: nil)
    }
    
    /// During the countdown the circles pulse. A pulse consists of the circle
    /// growing and shrinking while also becoming filled and then clear again.
    public func animatePulse() {
        let pulse                   = CABasicAnimation()
        pulse.keyPath               = Constants.scaleKeyPath
        pulse.fromValue             = currentScale()
        pulse.toValue               = 1.4
        pulse.duration              = delegate.circleSetPulseTime(self) / 2
        pulse.autoreverses          = true
        pulse.timingFunction        = CAMediaTimingFunction(name: .default)
        pulse.isRemovedOnCompletion = true
        layer.add(pulse, forKey: nil)
        
        let fill            = CABasicAnimation()
        fill.keyPath        = Constants.fillColorKeyPath
        fill.fromValue      = backgroundColor
        fill.toValue        = currentBorderColor()
        fill.duration       = delegate.circleSetPulseTime(self) / 2
        fill.autoreverses   = true
        fill.timingFunction = CAMediaTimingFunction(name: .default)
        fillLayer.add(fill, forKey: nil)
    }
    
    /// Called if this circle is chosen as a winner. The circle is expanded and
    /// filled. An emitter that shoots tiny circles is placed behind it.
    public func animateWin() {
        
        isWinner = true
        
        fillLayer.fillColor = currentBorderColor()
        
        let scale                   = CASpringAnimation()
        scale.keyPath               = Constants.scaleKeyPath
        scale.fromValue             = currentScale()
        scale.toValue               = 1.6
        scale.duration              = 1.5
        scale.damping               = 6.0
        scale.initialVelocity       = 3.1
        scale.timingFunction        = CAMediaTimingFunction(name: .default)
        scale.isRemovedOnCompletion = false
        transform                   = CGAffineTransform(scaleX: 1.6, y: 1.6)
        layer.add(scale, forKey: nil)
        
        let cell    = CAEmitterCell()
        let emitter = CAEmitterLayer()
        let image   = UIImage(named: Constants.emitterImageName)?.cgImage!
        
        cell.birthRate     = 75
        cell.lifetime      = 1
        cell.lifetimeRange = 0.25
        cell.velocity      = 160
        cell.velocityRange = 50
        cell.emissionRange = 2 * .pi
        cell.color         = color.cgColor
        cell.contents      = image
        cell.scale         = 0.1
        cell.scaleRange    = 0.3
        cell.alphaSpeed    = -1
        cell.alphaRange    = 0
        
        emitter.emitterPosition = CGPoint(x: Constants.radius, y: Constants.radius)
        emitter.emitterShape    = .circle
        emitter.emitterMode     = .outline
        emitter.emitterSize     = CGSize(width: Constants.radius, height: Constants.radius)
        emitter.emitterCells    = [cell]
        
        layer.insertSublayer(emitter, at: 0)
        
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: Constants.zRotationKeyPath)
        rotation.toValue               = 2 * Double.pi
        rotation.duration              = 10
        rotation.isCumulative          = true
        rotation.repeatCount           = Float.greatestFiniteMagnitude
        layer.add(rotation, forKey: nil)
    }
    

    // MARK: - Current State Helpers

    /// Finds the current scale.
    ///
    /// - Returns:
    ///     The current CGFloat of the scale.
    private func currentScale() -> CGFloat {
        return layer.presentation()?.value(forKeyPath: Constants.scaleKeyPath) as? CGFloat ?? 1.0
    }
    
    /// Finds the current opacity.
    ///
    /// - Returns:
    ///     The current CGFloat of the opacity.
    private func currentOpacity() -> CGFloat {
        return layer.presentation()?.value(forKeyPath: Constants.opacityKeyPath) as? CGFloat ?? 0.0
    }
    
    /// Finds the current border color.
    ///
    /// - Returns:
    ///     The current CGColor of the border.
    private func currentBorderColor() -> CGColor {
        return layer.presentation()?.value(forKey: Constants.borderColorKey) as! CGColor
    }
    
}

// MARK: - UICircleDelegate

protocol UICircleDelegate {
    func circleSetPulseTime(_ circle: CircleView) -> TimeInterval
    func circle(_ circle: CircleView, didRemoveFromSuperview wasWinner: Bool)
}

// MARK: - CAAnimationDelegate

extension CircleView: CAAnimationDelegate {
    
    /// We use this delegate for the exit scale animation. We need this
    /// because we have to tell the delegate that a circle has been removed and
    /// if that circle was a winning circle or not. If the removed circle was a
    /// winning circle the delegate is programmed to remove all the circles from
    /// the screen and make sure user interaction is enabled.
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == layer.animation(forKey: Constants.exitKey) {
            removeFromSuperview()
            delegate?.circle(self, didRemoveFromSuperview: isWinner)
        }
    }
}
