//
//  UICustomSelectionControl.swift
//  Chooser_4.0
//
//  Created by Matthew Marks on 7/25/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit

class CustomSegmentedControl: UIControl {

    // MARK: Constants & Variables
    
    /// Each item in this array will be a different selection option.
    private var items: [String]!
    
    /// Each item in the array will have a different UIButton it is associated in.
    private var itemButtons = [UIButton]()
    
    /// The current index of selection.
    public var selectedSegmentIndex: Int = 0 {
        didSet { selectButton(atIndex: selectedSegmentIndex) }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 7.0
        static let accentColor: UIColor  = .white
        static let borderWidth: CGFloat  = 1.5
    }
    
    // MARK: - Initialization
    convenience init(items: [String]) {
        self.init()
        self.items = items
        self.items.forEach({ _ in itemButtons.append(UIButton())})
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = Constants.cornerRadius
        layer.borderColor = Constants.accentColor.cgColor
        layer.borderWidth = Constants.borderWidth
        clipsToBounds = true
        if items.count > 0 {
            createSections()
            itemButtons[selectedSegmentIndex].clearColorForTitle()
        }
    }
    
    
    // MARK: - Bar & Button Creation
    
    /// Called when the segmented control is loaded.
    /// For each item a button is created and labeled.
    private func createSections() {
        let sectionWidth = bounds.width / CGFloat(items!.count)
        
        for i in 1..<items.count {
            let bar = CALayer()
            bar.backgroundColor = Constants.accentColor.cgColor
            bar.frame = CGRect(x: (CGFloat(i)*sectionWidth) - (Constants.borderWidth/2),
                                      y: 0,
                                      width: Constants.borderWidth,
                                      height: bounds.height)
            layer.addSublayer(bar)
        }
            
        for (i, items) in items.enumerated() {
            itemButtons[i].setTitle(items, for: .normal)
            itemButtons[i].setTitleColor(Constants.accentColor, for: .normal)
            itemButtons[i].titleLabel?.font = UIFont.tondo(weight: .regular, size: 14)
            itemButtons[i].frame = CGRect(x: CGFloat(i) * sectionWidth,
                                  y: 0,
                                  width: sectionWidth,
                                  height: bounds.height)
            itemButtons[i].addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
            addSubview(itemButtons[i])
        }
    }
    
    // MARK: - Selection
    
    /// Called when one of the item buttons is selected.
    /// Each button that is not the selected button become transparent,
    /// while the button at the selected index become opaque.
    ///
    /// - Parameters:
    ///     - index: An Int representing the index of the button that will be selected.
    private func selectButton(atIndex index: Int) {
        for (i, button) in itemButtons.enumerated() {
            if i == selectedSegmentIndex {
                button.backgroundColor = Constants.accentColor
                button.clearColorForTitle()
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(Constants.accentColor, for: .normal)
                button.layer.mask = nil
            }
        }
    }
    
    /// Called when one of the item buttons is selected.
    /// The selected segment index is updated to reflect the selection.
    /// The color of the buttons are updated to reflect the selection as well.
    ///
    /// - Parameters:
    ///     - sender: The UIButton that the user tapped on.
    @objc func buttonSelected(sender: UIButton) {
        selectedSegmentIndex = itemButtons.firstIndex(of: sender)!
        selectButton(atIndex: selectedSegmentIndex)
        if UserPreferences.vibrations {
            UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
        }
        sendActions(for: .valueChanged)
    }
}
