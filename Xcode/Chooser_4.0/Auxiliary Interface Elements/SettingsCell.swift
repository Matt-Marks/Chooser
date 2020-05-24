//
//  UICustomCell.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 6/9/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit

class SettingsCell: UIControl {
    
    // MARK: - Constants & Variables
    
    /// The background color of the cell itself.
    public var color: UIColor = UIColor.white.withAlphaComponent(0.1) {
        didSet {
            backgroundColor = color
        }
    }
    
    /// The color of the elements inside the cell.
    public var detailColor: UIColor = UIColor.white {
        didSet {
            titleLabel?.textColor   = detailColor
            chevronShape?.fillColor = detailColor.cgColor
            infoLabel?.textColor    = detailColor.withAlphaComponent(0.5)
        }
    }
    
    /// Represents if the entire cell is a button that can be selected or not.
    public var isSelectable: Bool = false
    
    /// We sometimes assign an ID to a cell to differentiate it.
    /// Currently this is only used in selectable cells.
    public var id: Int?           = nil
    
    /// The title that is left aligned in the cell.
    public var title: String?     = nil
    
    /// If true, the cell will have a chevron icon on the right.
    public var hasChevron: Bool   = false
    
    /// The info text that is right aligned in the cell.
    public var infoText: String?  = nil
    
    /// The object that holds and displays the title text.
    private var titleLabel: UILabel?        = nil
    
    /// The object that holds and displays the chevron shape.
    private var chevronView: UIView?        = nil
    
    /// The object that holds the chevron path.
    private var chevronShape: CAShapeLayer? = nil
    
    /// The object that holds and displays the info text.
    private var infoLabel: UILabel?         = nil
    
    private enum Constants {
        static let chevronSize: CGFloat      = 20.0
        static let chevronThickness: CGFloat = 3.0
        static let cornerRadius: CGFloat     = 15.0
        static let defaultHeight: CGFloat    = 60.0
        static let font: UIFont              = .tondo(weight: .regular, size: 16)
        static let padding: CGFloat          = 10.0
    }

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds      = true
        layer.cornerRadius = Constants.cornerRadius
        backgroundColor    = color
        if title != nil        { createTitleLabel() }
        if hasChevron != false { createChevron() }
        if infoText != nil     { createInfoLabel() }
    }
    
    // MARK: - Touch Event Handling
    
    /// Called whenever a user places a finger on the screen. The cell is selected,
    /// however the selection action does nto trigger until the touch is removed. 
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        if isSelectable { performTouchDownAnimation() }
        return true
    }
    
    /// Called when a finger is moving on the screen. If the finger moves outside of the
    /// cell the cell is de-selected.
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        if !bounds.contains(touch.location(in: self)) {
            if isSelectable { performTouchUpAnimation() }
        }
        return true
    }

    /// Called when a user lifts their finger from the screen.
    /// If the touch was still within the cell when the finger is lifted form the screen
    /// we trigger an action. The cell is de-selected no matter what.
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if touch != nil && bounds.contains(touch!.location(in: self)) {
            sendActions(for: .touchUpInside)
        }
        if isSelectable { performTouchUpAnimation() }
    }
    
    /// This is called when the user recieves a phone call, switches apps, etc.
    /// All this does is call the touch up animation do de-select the cell.
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        if isSelectable { performTouchUpAnimation() }
    }
 
    // MARK: - Animations
    
    /// This is only called if 'isSelectable' is true. It is called then the user touches
    /// their finger down on a cell. This changes the background color to a darker color
    /// and shrinks the cell just a bit.
    private func performTouchDownAnimation() {
        backgroundColor = color.withAlphaComponent(0.3)
        transform = CGAffineTransform.init(scaleX: 0.97, y: 0.97)
    }
    
    /// This is only called if 'isSelectable' is true. It is called then the user lifts
    /// their finger up from the cell. This method changed the cell's background color
    /// back to its normal background color and rescales the cell back to its
    /// original size.
    private func performTouchUpAnimation() {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        self.backgroundColor = self.color
                        self.transform = .identity
        })
    }
    
    // MARK: - Title Label
    
    /// When this view's subviews are laid out, if the 'title' has been set, this
    /// method has been called. The title is stored in a UILabel, that is created by this
    /// method, to the left hand side of the cell.
    private func createTitleLabel() {
        if titleLabel == nil {
            titleLabel = UILabel()
            let leftConstant = (Constants.defaultHeight - Constants.font.pointSize)/2
            addSubview(titleLabel!)
            titleLabel!.text = title!
            titleLabel!.font = Constants.font
            titleLabel!.textColor = detailColor
            titleLabel!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel!.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel!.leftAnchor.constraint(equalTo: leftAnchor,
                                                  constant: leftConstant)
            ])
        }
    }
    
    // MARK: - Chevron Indicator
    
    /// When this view's subviews are laid out, if the 'hasChevron' boolean is true, this
    /// method is called. The chevron is drawn in a CAShapeLayer that is added to a
    /// UIView (both of which are created by this method). The chevron is placed to the
    /// right hand side of the view.
    private func createChevron() {
        
        // If the chevron already exists we do nothing.
        if chevronView == nil  {
            let frame = CGRect(x: 0, y: 0, width: Constants.chevronSize, height: Constants.chevronSize)
            let rightConstant = -(Constants.defaultHeight - Constants.chevronSize)/2
            chevronView = UIView()
            addSubview(chevronView!)
            chevronView!.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                chevronView!.widthAnchor.constraint(equalToConstant: Constants.chevronSize),
                chevronView!.heightAnchor.constraint(equalToConstant: Constants.chevronSize),
                chevronView!.centerYAnchor.constraint(equalTo: centerYAnchor),
                chevronView!.rightAnchor.constraint(equalTo: rightAnchor,
                                                    constant: rightConstant)
            ])
            chevronShape = CAShapeLayer()
            chevronView!.layer.addSublayer(chevronShape!)
            chevronShape!.frame = frame
            chevronShape!.path = UIBezierPath(chevronIn: frame,
                                              thickness: Constants.chevronThickness).cgPath
            chevronShape!.fillColor = detailColor.cgColor
        }
    }
    
    // MARK: - Info Label
    
    /// When this view's subviews are laid out, if the user has the info text, this
    /// method is called. The info text is stored in a UILabel, that is created by this
    /// method, to the right hand side of the cell.
    private func createInfoLabel() {
        
        // If the label already exists we do nothing.
        if infoLabel == nil {
            infoLabel = UILabel()
            addSubview(infoLabel!)
            infoLabel!.text = infoText
            infoLabel!.font = Constants.font
            infoLabel!.textColor = detailColor.withAlphaComponent(0.5)
            infoLabel!.translatesAutoresizingMaskIntoConstraints = false
            
            // The label's right anchor has a different constant depending on if the
            // cell has a chevron or not.
            if hasChevron {
                let rightConstant = -(Constants.defaultHeight - Constants.chevronSize/2)
                NSLayoutConstraint.activate([
                    infoLabel!.centerYAnchor.constraint(equalTo: centerYAnchor),
                    infoLabel!.rightAnchor.constraint(equalTo: rightAnchor,
                                                      constant: rightConstant)
                ])
            } else {
                let rightConstant = -(Constants.defaultHeight - Constants.font.pointSize)/2
                NSLayoutConstraint.activate([
                    infoLabel!.centerYAnchor.constraint(equalTo: centerYAnchor),
                    infoLabel!.rightAnchor.constraint(equalTo: rightAnchor,
                                                      constant: rightConstant)
                ])
            }
        }
    }
    
    
}






