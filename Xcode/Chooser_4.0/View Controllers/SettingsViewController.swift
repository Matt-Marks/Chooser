//
//  FancySettingsViewController.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 5/22/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
        //

import UIKit
import MessageUI

fileprivate extension Selector {
    static let dismissPressed    = #selector(SettingsViewController.dismissPressed)
    static let winnersChanged    = #selector(SettingsViewController.winnersChanged)
    static let soundsToggled     = #selector(SettingsViewController.soundsToggled)
    static let vibrationsToggled = #selector(SettingsViewController.vibrationsToggled)
    static let appIconSelected   = #selector(SettingsViewController.appIconPressed)
    static let themePressed      = #selector(SettingsViewController.themePressed)
    static let cellSelected      = #selector(SettingsViewController.cellSelected)
}

class SettingsViewController: UIViewController {
    
    // MARK: - Constants & Variables
    
    public var state: State = .button {
        didSet {
            if state == .button {
                dismissButton.isHidden = true
                mainScrollView.setContentOffset(.zero, animated: false)
            } else {
                dismissButton.isHidden = false
            }
            mainViewController.settingsViewDidUpdateState(toState: state)
        }
    }
    
    private var mainViewController: ChooserViewController!
    private var extraBackgroundButton = UIButton() // Used to prevent touch passthrough
    private var titleButton    = UIButton()
    private var dismissButton  = UIButton()
    private var mainScrollView = UIScrollView()
    private var mainStackView  = UIStackView()
    private var shadowLayer    = CAGradientLayer()
    private var iconButtons    = [AppIconButton]()
    private var themeButtons   = [ThemeButton]()
    
    public enum State { case button, menu }
    
    private enum CellID: Int {
        case review, feedback, twitter, carbon
    }
    
    public enum Constants {
        enum Color {
            static let accent: UIColor = .white
        }
        enum SectionHeader {
            static let general: String = "GENERAL"
            static let appIcon: String = "APP ICON"
            static let theme: String   = "THEME"
            static let contact: String = "CONTACT"
            static let apps: String    = "APPS BY NANOTUBE"
        }
        enum CellTitleText {
            static let settings: String   = "SETTINGS"
            static let winners: String    = "Winners"
            static let sounds: String     = "Sounds"
            static let vibrations: String = "Vibrations"
            static let review: String     = "Write a Review"
            static let feedback: String   = "Submit Feedback"
            static let twitter: String    = "Twitter"
            static let carbon: String     = "CARBON"
        }
        enum CellAuxiliaryText {
            static let twitter: String      = "@Matt__Marks"
            static let carbon: String       = "MTG Tabletop Utility"
            static let winnerNums: [String] = ["1", "2", "3", "4"]
        }
        enum Font {
            static let title: UIFont  = .tondo(weight: .bold, size: 23)
            static let header: UIFont = .tondo(weight: .light, size: 13)
            static let cell: UIFont   = .tondo(weight: .regular, size: 16)
        }
        enum Dimensions {
            static let padding: CGFloat                       = 10.0
            static let cellCornerRadius: CGFloat              = 15
            static let headerHeight: CGFloat                  = 30
            static let chevronSize: CGFloat                   = 20
            static let chevronThickness: CGFloat              = 3
            static let dismissButtonSize: CGFloat             = 23
            static let dismissButtonSaltireThickness: CGFloat = 3
            static let dismissButtonSaltireScale: CGFloat     = 1.0
            static let titleButtonHeight: CGFloat             = 70
            static let titleButtonWidth: CGFloat              = 160
            static let cornerRadius: CGFloat                  = 10.0
        }
        enum CellHeight {
            static let large: CGFloat   = 96
            static let medium: CGFloat  = 86
            static let regular: CGFloat = 60
        }
        enum Image {
            static let carbonIconName: String = "Carbon"
        }
        enum IDS {
            static let chooserAppID: String         = "1275945156"
            static let carbonAppID: String          = "1209153225"
            static let chooserAppURL: String        = "https://itunes.apple.com/us/app/id\(chooserAppID)?mt=8&action=write-review"
            static let carbonAppURL: String         = "https://itunes.apple.com/us/app/id\(carbonAppID)?mt=8"
            static let feedbackEmail: String        = "feedback@nanotubeapps.com"
            static let feedbackEmailSubject: String = "Chooser Feedback"
            static let twitterUsername: String      = "Matt__Marks"
            static let twitterAppURL: String        = "twitter://user?screen_name=\(twitterUsername)"
            static let twitterWebURL: String        = "https://twitter.com/\(twitterUsername)"
        }
    }
    
    // MARK: - Initialization
    convenience init(mainViewController: ChooserViewController) {
        self.init()
        self.mainViewController = mainViewController
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.layer.cornerRadius = Constants.Dimensions.cornerRadius
        createTitleButton()
        createDismissButton()
        createScrollView()
        createStackView()
        addSectionHeader(text: Constants.SectionHeader.general)
        createWinnersCell()
        createSoundsCell()
        if UIDevice.current.userInterfaceIdiom == .phone { createVibrationsCell() }
        addSectionHeader(text: Constants.SectionHeader.appIcon)
        createAppIconCell()
        addSectionHeader(text: Constants.SectionHeader.theme)
        createThemeCell()
        addSectionHeader(text: Constants.SectionHeader.contact)
        createReviewCell()
        createFeedbackCell()
        createTwitterCell()
        addSectionHeader(text: Constants.SectionHeader.apps)
        createCarbonAppCell()
        createExtraBackgroundButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createShadowLayer()
    }
    
    // MARK: - Extra Background Button
    
    /// This is used to prevent touch passthrough.
    /// A button is placed below the header bar of the settings menu.
    /// Though it is used to prevent touch passthrough, we also double it as a
    /// dismiss button because why not? May as well make the X easier to press.
    private func createExtraBackgroundButton() {
        view.addSubview(extraBackgroundButton)
        extraBackgroundButton.translatesAutoresizingMaskIntoConstraints = false
        extraBackgroundButton.addTarget(self, action: #selector(dismissPressed), for: .touchUpInside)
        NSLayoutConstraint.activate([
            extraBackgroundButton.topAnchor.constraint(equalTo: view.topAnchor),
            extraBackgroundButton.leftAnchor.constraint(equalTo: view.leftAnchor),
            extraBackgroundButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            extraBackgroundButton.bottomAnchor.constraint(equalTo: mainScrollView.topAnchor)
        ])
        view.sendSubviewToBack(extraBackgroundButton)
    }

    // MARK: - Title Label
    
    /// A title button is added to the top of the settings menu.
    /// It is constrained to the top left corner. The reason this is a button is a bit strange.
    /// We make the title a button instead of a label because when the settings menu is collapsed,
    /// all that is visible is the settings button. Then, we use the settings button as the
    /// trigger to expand the settings menu. This is weird, but sometimes you gotta
    /// do some strange shit to get the animations you want.
    private func createTitleButton() {
        view.addSubview(titleButton)
        titleButton.setTitle(Constants.CellTitleText.settings, for: .normal)
        titleButton.titleLabel?.font = Constants.Font.title
        titleButton.setTitleColor(Constants.Color.accent, for: .normal)
        titleButton.translatesAutoresizingMaskIntoConstraints = false
        titleButton.addTarget(self, action: #selector(titleButtonPressed), for: .touchUpInside)
        titleButton.titleLabel?.textAlignment = .center
        NSLayoutConstraint.activate([
            titleButton.topAnchor.constraint(equalTo: view.topAnchor),
            titleButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            titleButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.titleButtonWidth),
            titleButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.titleButtonHeight)
        ])
    }
    
    /// Called when the settings button is pressed. The settings menu is expanded.
    ///
    /// - Parameters:
    ///     - sender: The UIButton that has 'SETTINGS' as it's title.
    @objc public func titleButtonPressed(sender: UIButton) {
        state = .menu
    }
    
    // MARK: - Dismiss Button
    
    /// The dismiss button is the small button in the top right corner with an 'X' on it.
    /// When pressed, the settings menu collapses. This adds the button to the view and configures it accordingly.
    private func createDismissButton() {
        
        view.addSubview(dismissButton)
        
        let buttonBounds = CGRect(origin: .zero, size: CGSize(width: Constants.Dimensions.dismissButtonSize, height: Constants.Dimensions.dismissButtonSize))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath.init(saltireIn: buttonBounds,
                                            thickness: Constants.Dimensions.dismissButtonSaltireThickness,
                                            scale: Constants.Dimensions.dismissButtonSaltireScale).cgPath
        shapeLayer.frame = buttonBounds
        shapeLayer.fillColor = Constants.Color.accent.cgColor
        
        dismissButton.layer.addSublayer(shapeLayer)
        dismissButton.addTarget(self, action: .dismissPressed, for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.isHidden = true
        
        NSLayoutConstraint.activate([
            dismissButton.centerYAnchor.constraint(equalTo: titleButton.centerYAnchor),
            dismissButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                 constant: -Constants.Dimensions.padding - Constants.Dimensions.cellCornerRadius),
            dismissButton.widthAnchor.constraint(equalToConstant: Constants.Dimensions.dismissButtonSize),
            dismissButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.dismissButtonSize)
        ])
    }
    
    /// Called when the dismiss button is pressed.
    /// The settings menu is collapsed back into button form.
    @objc public func dismissPressed() {
        state = .button
    }
    
    // MARK: - Scroll View
    
    /// The main scroll view fills the entire settings menu (under the header at least).
    /// The main scroll view contains a stack view that holds the cells that comprise the
    /// settings menu. We set the scroll view delegate to this class because we need to
    /// keep track of the scroll offset so we can add a slight shadow under the header
    /// when scrolling is or has happened.
    private func createScrollView() {
        mainScrollView = addScrollView(toView: view,
                                   topConstraint: titleButton.bottomAnchor,
                                   topConstraintConstant: 0)
        mainScrollView.delegate = self
        
    }
    
    // MARK: - Stack View
    
    /// The stack view is placed in the main scrol view. The stack view constains all the
    /// cells of the settings menu as subviews.
    private func createStackView() {
        mainStackView = addStackView(toView: mainScrollView, axis: .vertical, spacing: Constants.Dimensions.padding)
        mainStackView.layoutMargins = UIEdgeInsets(top: 0,
                                               left: Constants.Dimensions.padding,
                                               bottom: Constants.Dimensions.padding,
                                               right: Constants.Dimensions.padding)
    }
    

    // MARK: - Winners
    
    /// Adds a cell that lets the user modify the number of winners to the main stack
    /// stack view.
    private func createWinnersCell() {
        
        // Necessary Constants
        let cellHeight = Constants.CellHeight.regular
        let padding = Constants.Dimensions.padding
        let height = cellHeight - 3*padding
        
        // Creation of the cell itself.
        let cell = addCell(stack: mainStackView, height: cellHeight, selectable: false)
        
        // Setting of cell title.
        cell.title = Constants.CellTitleText.winners

        // Making the segmented control for the winners.
        let segCon = CustomSegmentedControl(items: Constants.CellAuxiliaryText.winnerNums)
        cell.addSubview(segCon)
        segCon.translatesAutoresizingMaskIntoConstraints = false
        segCon.addTarget(self, action: .winnersChanged, for: .valueChanged)
        segCon.selectedSegmentIndex = UserPreferences.numberOfWinners - 1
        NSLayoutConstraint.activate([
            segCon.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            segCon.heightAnchor.constraint(equalToConstant: height),
            segCon.widthAnchor.constraint(equalToConstant: 4 * height),
            segCon.rightAnchor.constraint(equalTo: cell.rightAnchor,
                                          constant: -3*padding/2)
        ])
    }
    
    /// Called when the user changed the number of winners. If the user does not own pro
    /// the in app purchase screen is displayed so the user can upgrade. Otherwise, the
    /// the number of winners is updated.
    ///
    /// - Parameters:
    ///     - sender: The UISegmentedControl view associated with the number of winners.
    @objc func winnersChanged(_ sender: CustomSegmentedControl) {
        UserPreferences.numberOfWinners = sender.selectedSegmentIndex + 1
        mainViewController.updateInstructionsLabel(forNumberOfWinners: UserPreferences.numberOfWinners)
    }
    
    // MARK: - Sounds
    
    /// Adds a cell containing a toggle button that lets the user
    /// turn the sound on and off.
    private func createSoundsCell() {
        let cellHeight = Constants.CellHeight.regular
        let cell = addCell(stack: mainStackView, height: cellHeight, selectable: false)
        cell.title = Constants.CellTitleText.sounds
        let toggleSwitch = addToggleSwitch(cell: cell)
        toggleSwitch.isOn = UserPreferences.sounds
        toggleSwitch.addTarget(self, action: .soundsToggled, for: .valueChanged)
    }
    
    /// Called when the user toggles the sound on and off.
    /// The sound is toggled. The state of the switch is updated to
    /// represent that change.
    ///
    /// - Parameters:
    ///     - sender: The toggle button that the user presses.
    @objc fileprivate func soundsToggled(_ sender: CustomSwitch) {
        UserPreferences.sounds.toggle()
    }
    
    // MARK: - Vibrations
    
    /// Adds a cell containing a toggle button that lets the user
    /// turn vibrations on and off.
    private func createVibrationsCell() {
        let cellHeight = Constants.CellHeight.regular
        let cell = addCell(stack: mainStackView, height: cellHeight, selectable: false)
        cell.title = Constants.CellTitleText.vibrations
        let toggleSwitch = addToggleSwitch(cell: cell)
        toggleSwitch.isOn = UserPreferences.vibrations
        toggleSwitch.addTarget(self, action: .vibrationsToggled, for: .valueChanged)
    }
    
    /// Called when the user toggles the vibrations on and off.
    /// The vibrations are toggled. The state of the switch is updated to
    /// represent that change.
    ///
    /// - Parameters:
    ///     - sender: The toggle button that the user presses.
    @objc fileprivate func vibrationsToggled(_ sender: CustomSwitch) {
        UserPreferences.vibrations.toggle()
    }
    
    // MARK: - App Icon
    
    /// The app icon cell is a cell that constains a stack view.
    /// The subviews in this nested stack view are the app icon buttons themselves.
    private func createAppIconCell() {
        let cell = addCell(stack: mainStackView,
                           height: Constants.CellHeight.medium,
                           selectable: false)
        let scrollView = addScrollView(toView: cell,
                                       topConstraint: cell.topAnchor,
                                       topConstraintConstant: 0)
        
        let stackView = addStackView(toView: scrollView, axis: .horizontal,
                                     spacing: Constants.Dimensions.padding
        )
        
        stackView.layoutMargins = UIEdgeInsets(top: Constants.Dimensions.padding,
                                               left: Constants.Dimensions.padding,
                                               bottom: Constants.Dimensions.padding,
                                               right: Constants.Dimensions.padding)
        
        for (i, icon) in AppIcon.allCases.enumerated() {
            let iconButton = AppIconButton()
            let currIconName = UIApplication.shared.alternateIconName
            iconButtons.append(iconButton)
            iconButton.tag = i
            iconButton.topColor = icon.colors.first!
            iconButton.bottomColor = icon.colors.last!
            iconButton.widthAnchor.constraint(equalTo: iconButton.heightAnchor).isActive = true
            iconButton.addTarget(self, action: .appIconSelected, for: .touchUpInside)
            stackView.addArrangedSubview(iconButton)
            if currIconName == icon.name {
                iconButton.setChosen(true, animated: false)

            // This else is there to select the correct icon when the user has never changed the icon before. 
            } else if currIconName == nil && icon.name == AppIcon.Neon.name {
                iconButton.setChosen(true, animated: false)
            }
        }
        
    }
    
    /// Called when a user selects a new app icon.
    /// The icon is updated and the settings menu is updated to reflect the change by
    /// outlining the selected button.
    @objc func appIconPressed(_ sender: UIButton) {
        let selectedIcon = AppIcon.init(rawValue: sender.tag)!
        UIApplication.shared.setAlternateIconName(selectedIcon.name)
        iconButtons.forEach({$0.setChosen($0.isEqual(sender), animated: true)})
        if UserPreferences.vibrations {
            UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
        }
    }
    
    // MARK: - Theme
    
    /// The theme cell is a cell that constains a stack view.
    /// The subviews in this nested stack view are the theme buttons themselves.
    private func createThemeCell() {
        let cell = addCell(stack: mainStackView,
                           height: Constants.CellHeight.large,
                           selectable: false)
        let scrollView = addScrollView(toView: cell,
                                       topConstraint: cell.topAnchor,
                                       topConstraintConstant: 0)
        let stackView = addStackView(toView: scrollView, axis: .horizontal, spacing: 2*Constants.Dimensions.padding)
        stackView.layoutMargins = UIEdgeInsets(top: Constants.Dimensions.padding,
                                               left: 2*Constants.Dimensions.padding,
                                               bottom: Constants.Dimensions.padding,
                                               right: 2*Constants.Dimensions.padding)
        
        for (i, gradient) in BackgroundGradient.allCases.enumerated() {
            let rectHeight = Constants.CellHeight.large - 2*Constants.Dimensions.padding
            let rectWidth = rectHeight / 1.4
            let gradientButton = ThemeButton()
            themeButtons.append(gradientButton)
            gradientButton.tag = i
            gradientButton.topColor = gradient.colors.first!
            gradientButton.bottomColor = gradient.colors.last!
            gradientButton.widthAnchor.constraint(equalToConstant: rectWidth).isActive = true
            gradientButton.addTarget(self, action: .themePressed, for: .touchUpInside)
            stackView.addArrangedSubview(gradientButton)
            
            if UserPreferences.backgroundGradient == gradient {
                gradientButton.setChosen(true, animated: false)
            }
        }
        
    }
    
    /// Called when a user selects a new theme.
    /// The theme is updated and the settings menu is updated to reflect the change by
    /// outlining the selected button.
    @objc func themePressed(_ sender: ThemeButton) {
        let selectedTheme = BackgroundGradient.init(rawValue: sender.tag)!
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let root = delegate.window?.rootViewController
        let chooser = root as! ChooserViewController
        UserPreferences.backgroundGradient = selectedTheme
        chooser.setBackgroundGradient(selectedTheme)
        themeButtons.forEach({$0.setChosen($0.isEqual(sender), animated: true)})
        if UserPreferences.vibrations {
            UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
        }
    }
    
    // MARK: - Review
    
    /// Creates and adds a cell with the title 'Write a Review'.
    private func createReviewCell() {
        let cell = addCell(stack: mainStackView, height: Constants.CellHeight.regular, selectable: true)
        cell.addTarget(self, action: .cellSelected, for: .touchUpInside)
        cell.id = CellID.review.rawValue
        cell.title = Constants.CellTitleText.review
        cell.hasChevron = true
    }
    
    // MARK: - Feedback
    
    /// Creates and adds a cell with the title 'Submit Feedback'.
    private func createFeedbackCell() {
        let cell = addCell(stack: mainStackView, height: Constants.CellHeight.regular, selectable: true)
        cell.addTarget(self, action: .cellSelected, for: .touchUpInside)
        cell.id = CellID.feedback.rawValue
        cell.title = Constants.CellTitleText.feedback
        cell.hasChevron = true
    }
    
    // MARK: - Twitter
    
    /// Creates and adds a cell with the title 'twitter'.
    private func createTwitterCell() {
        let cell = addCell(stack: mainStackView, height: Constants.CellHeight.regular, selectable: true)
        cell.addTarget(self, action: .cellSelected, for: .touchUpInside)
        cell.id = CellID.twitter.rawValue
        cell.title = Constants.CellTitleText.twitter
        cell.hasChevron = true
        cell.infoText = Constants.CellAuxiliaryText.twitter
    }
    
    // MARK: - Carbon App
    
    /// Creates and adds a cell with the title 'Carbon'.
    /// This cell links to the Carbon app in the app store.
    private func createCarbonAppCell() {
        let cell = addCell(stack: mainStackView, height: Constants.CellHeight.medium, selectable: true)
        cell.addTarget(self, action: .cellSelected, for: .touchUpInside)
        cell.id = CellID.carbon.rawValue
        let iconSize = Constants.CellHeight.medium - 2*Constants.Dimensions.padding
        let icon = UIImageView(image: UIImage(named: Constants.Image.carbonIconName))
        icon.layer.cornerRadius = iconSize/4
        icon.clipsToBounds = true
        
        cell.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            icon.heightAnchor.constraint(equalToConstant: iconSize),
            icon.widthAnchor.constraint(equalToConstant: iconSize),
            icon.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            icon.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: Constants.Dimensions.padding)
        ])
        
        let carbonLabel = UILabel()
        carbonLabel.text = Constants.CellTitleText.carbon
        carbonLabel.font = .tondo(weight: .bold, size: 27)
        carbonLabel.textColor = Constants.Color.accent
        cell.addSubview(carbonLabel)
        carbonLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            carbonLabel.lastBaselineAnchor.constraint(equalTo: cell.centerYAnchor, constant: -Constants.Dimensions.padding/3),
            carbonLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: Constants.Dimensions.padding)
        ])
        
        let appInfoLabel = UILabel()
        appInfoLabel.text = Constants.CellAuxiliaryText.carbon
        appInfoLabel.font = .tondo(weight: .light, size: 16)
        appInfoLabel.textColor = Constants.Color.accent
        cell.addSubview(appInfoLabel)
        appInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            appInfoLabel.topAnchor.constraint(equalTo: cell.centerYAnchor, constant: Constants.Dimensions.padding/3),
            appInfoLabel.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: Constants.Dimensions.padding)
        ])
        
        cell.hasChevron = true
    }
    
    // MARK: - Shadow Layer
    
    /// When the user scrolls in the settings, a shadow is added underneath the header
    /// to make the settings menu look better. This shadow starts as invisible, but gains
    /// opacity as the user scrolls.
    private func createShadowLayer() {
        let currLayers = view.layer.sublayers
        if currLayers != nil && !currLayers!.contains(shadowLayer) {
            view.layer.addSublayer(shadowLayer)
        }
        shadowLayer.colors = [UIColor.black.withAlphaComponent(0.1).cgColor, UIColor.clear.cgColor]
        shadowLayer.opacity = 0.0
        updateShadowLayerFrame()
    }
    
    /// We constantly need to update the shadows frame because we are NOT using constraints to place
    /// it in the correct position. We can't constrain a layer, we can only constrain views. 
    private func updateShadowLayerFrame() {
        shadowLayer.frame = CGRect(x: 0, y: mainScrollView.frame.origin.y, width: view.bounds.width, height: 20)
    }
    
    
           
    
    // MARK: Cell Selection
    
    /// Called when one of the selectable cells is selected. Currently these cells are the
    /// review cell, the feedback cell, the twitter cell, and the Carbon app cell. The selected cell
    /// is identified in this method with a variable called 'id'. The id of the cell determines the action
    /// the cell makes.
    ///
    /// - Parameters:
    ///     - sender: The UICustomCell that the user has selected.
    @objc func cellSelected(_ sender: SettingsCell) {
        
        switch sender.id! {
        case CellID.review.rawValue:
            let urlStr = Constants.IDS.chooserAppURL
            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        case CellID.feedback.rawValue:
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([Constants.IDS.feedbackEmail])
                mail.setSubject(Constants.IDS.feedbackEmailSubject)
                present(mail, animated: true)
            } else {
                // show failure alert
            }
        case CellID.twitter.rawValue:
            let appURL = NSURL(string: Constants.IDS.twitterAppURL)!
            let webURL = NSURL(string: Constants.IDS.twitterWebURL)!

            let application = UIApplication.shared

            if application.canOpenURL(appURL as URL) {
                application.open(appURL as URL)
            } else {
                application.open(webURL as URL)
            }
        case CellID.carbon.rawValue:
            let urlStr = Constants.IDS.carbonAppURL

            if let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        default: () // We Do Nothing
        }
    }
    
    // MARK: - Helpers & Utilities
    
    /// Adds a section header to the main stack view.
    /// The section header is a customized UILabel class.
    ///
    /// - Parameters:
    ///     - text: A string representing the name of the section header.
    private func addSectionHeader(text: String) {
        
        // We need to do two custom things to the UILabel. First, we need to vertically
        // align the text with the bottom of the label. Second, we need to add a bit of
        // spacing to the left of the text within the label. The only way to do these
        // two things is to override the 'drawText' function in the UILabel class.
        // Thus, we make a custom UILabel class within this funciton.
        class PaddedLabel: UILabel {
            override func drawText(in rect: CGRect) {
                let top = Constants.Dimensions.headerHeight - Constants.Font.header.pointSize
                let left = Constants.Dimensions.cellCornerRadius
                let insets = UIEdgeInsets(top: top, left: left, bottom: 0, right: 0)
                super.drawText(in: rect.inset(by: insets))
            }
        }
        
        // We create the label and add it to the cell.
        let label = PaddedLabel()
        mainStackView.addArrangedSubview(label)
        label.text = text
        label.font = Constants.Font.header
        label.textColor = Constants.Color.accent.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: Constants.Dimensions.headerHeight)
        ])
    }
    
    /// Adds a cell with the given height to the given stack.
    ///
    /// - Parameters:
    ///     - stack: The stack that the cell will be added to.
    ///     - height: The intended height of the cell.
    ///     - selectable: A boolean representing if the cell should perform a
    ///                   selection animation when touched.
    private func addCell(stack: UIStackView, height: CGFloat, selectable: Bool) -> SettingsCell {
        let cell = SettingsCell()
        cell.isSelectable = selectable
        stack.addArrangedSubview(cell)
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(equalToConstant: height).isActive = true
        return cell
    }

    /// Adds a scroll view to the given view. The scroll view is constrained to fill the
    /// view - aside from one exception: the top constraint. The main settings scroll
    /// view, that holds the stack view, needs to not fill the entire screen. Instead, the
    /// top of the scroll view needs to be constrained to the bottom of the 'settings'
    /// label. Due to this, we pass in a top constraint and constant as parameters so we
    /// can use this function for both the main scroll view and the scroll views within
    /// cells.
    ///
    /// - Parameters:
    ///     - item: The view that will be the superview of the scroll view.
    ///     - topConstraint: The anchor that the scroll view's top will attach to.
    ///     - topConstraintConstant: The constant for the previous parameter.
    ///
    /// - Returns:
    ///     The scroll view that is created.
    private func addScrollView(toView item: UIView,
                               topConstraint: NSLayoutYAxisAnchor,
                               topConstraintConstant: CGFloat) -> UIScrollView {
        let scrollView = UIScrollView()
        item.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: item.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: item.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: item.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: topConstraint,
                                            constant: topConstraintConstant)
        ])
        
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }
    
    /// Adds a stack view to the given view. The stack view is constrained to fill the
    /// entire view given in the parameter.
    ///
    /// - Parameters:
    ///     - item: The view that will be the superview of the stack view.
    ///     - axis: The axis, either vertical or horizontal, of the stack view.
    ///     - spacing: The spacing around each item in the stack view.
    ///
    /// - Returns:
    ///     The stack view that is created.
    private func addStackView(toView item: UIView,
                              axis: NSLayoutConstraint.Axis,
                              spacing: CGFloat) -> UIStackView {
        
        let stackView = UIStackView()
        item.addSubview(stackView)
        
        stackView.axis = axis
        stackView.alignment = .fill
        stackView.spacing = spacing
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // The stack view, since it is always used within a scroll view in this class,
        // needs to be constrained in a strange way. We have to first constrain all the
        // edges of the stack view. Then, we need to constrain the stack views height or
        // width. It is essential to make these constrains like this, otherwise the scroll
        // view will not display the stack view.
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: item.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: item.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: item.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: item.bottomAnchor),
        ])
        
        if axis == .horizontal {
            stackView.heightAnchor.constraint(equalTo: item.heightAnchor).isActive = true
        } else {
            stackView.widthAnchor.constraint(equalTo: item.widthAnchor).isActive = true
        }
        
        return stackView
    }

    /// Adds a switch that represents the binary selection of the cell to the given cell.
    ///
    /// - Parameters:
    ///     - cell: The cell that the switch will be added to.
    ///
    /// - Returns:
    ///     The switch that is created and added to the cell.
    private func addToggleSwitch(cell: SettingsCell) -> CustomSwitch {
        let height = Constants.CellHeight.regular - 3*Constants.Dimensions.padding
        let rightPadding = -3*Constants.Dimensions.padding/2
        let customSwitch = CustomSwitch(frame: CGRect(x: 0, y: 0, width: 1.6 * height, height: height))
        cell.addSubview(customSwitch)
        customSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customSwitch.widthAnchor.constraint(equalToConstant: 1.6 * height),
            customSwitch.heightAnchor.constraint(equalToConstant: height),
            customSwitch.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            customSwitch.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: rightPadding)
        ])
        return customSwitch
    }

}


// MARK: - MFMailComposeViewControllerDelegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    /// We impliment this delegate method so we can dismiss the email
    /// prompt that appears after the user submits feedback.
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
    
}


// MARK: - UIScrollViewDelegate

extension SettingsViewController: UIScrollViewDelegate {
    
    /// We impliment this delegate method to control the shadow that appears
    /// under the header. When the settings menu is scrolled all the way to
    /// the top there will be no shadow. As soon as scroll starts a
    /// shadow appears.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        updateShadowLayerFrame()
        
        let yPos = scrollView.contentOffset.y
        
        if yPos <= 0 {
            shadowLayer.opacity = 0.0
        }
        
        if yPos > 0 && yPos <= Constants.Dimensions.headerHeight {
            shadowLayer.opacity = Float (yPos / Constants.Dimensions.headerHeight)
        }
        
        if yPos > Constants.Dimensions.headerHeight {
            shadowLayer.opacity = 1.0
        }
        
    }
}
