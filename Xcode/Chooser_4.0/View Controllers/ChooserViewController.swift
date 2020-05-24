//
//  ViewController.swift
//  Chooser_4.0
//
//  Created by Matt Marks on 2/11/19.
//  Copyright © 2019 Matt Marks. All rights reserved.
//

import UIKit
import StoreKit
import AudioToolbox
import AVFoundation

class ChooserViewController: UIViewController {
    
    
    // MARK: - Constants & Variables
    
    /// The large 'Finger Chooser' title.
    private var titleLabel = UILabel()
    
    /// The small line seperating the title and the instructions.
    private var seperatorLineView = UIView()
    
    /// The instructions text.
    private var instructionsLabel = UILabel()
    
    /// The background is made by this gradient layer.
    private var gradient = CAGradientLayer()
    
    /// The types of constraints the settings view controller has.
    private enum SettingsConstraints { case top, bottom, width, centerX }
    
    /// The button that appears behind the settings view controller in it's expanded form on large divices.
    private var dimOverlayButton = UIButton()
    
    /// The entire settings menu itself.
    private var settingsViewController = SettingsViewController()
    
    /// The top constraint for the settings view controller.
    private var settingsViewTopConstraint: NSLayoutConstraint!
    
    /// The bottom constraint for the settings view controller.
    private var settingsViewBottomConstraint: NSLayoutConstraint!
    
    /// The width constraint for the settings view controller.
    private var settingsViewWidthConstraint: NSLayoutConstraint!
    
    /// The horizontal center constraint for the settings view controller.
    private var settingsViewCenterXConstraint: NSLayoutConstraint!

    /// This dictionary holds the users touch as a value and the circle as the key.
    /// This is constantly updated so it always represents the current touches on the screen.
    private var circles = [UITouch : CircleView]()
    
    /// This is the timer that is used to triger the animation for the circles
    private var countdown: Timer?
    
    /// The current count represents how many times circles have pulsed during the chosing sequence.
    private var currCount: Int = 0
    
    /// The object used to play sound effects. Each sound effect will have its own audio player.
    private var audioPlayers = [SoundEffect : AVAudioPlayer]()
    
    /// A flag that indicates if a winner has been chosen.
    private var hasWinner: Bool = false {
        didSet {
            // If the is a winner, nothing can happen until the winner(s) has lifted their finger.
            view.isUserInteractionEnabled = !hasWinner
        }
    }

    private enum Constants {
        static let circleColor: UIColor                              = .white
        static let maxCount: Int                                     = 2
        static let countDuration: TimeInterval                       = 1.0
        static let formSheetWindowHeight: CGFloat                    = 620.0
        static let formSheetWindowWidth: CGFloat                     = 540.0
        static let settingsBorderWidth: CGFloat                      = 1.0
        static let settingsBorderColor: UIColor                      = .white
        static let settingsButtonVerticalOffset: CGFloat             = 50.0
        static let settingsAnimationDuration: TimeInterval           = 0.6
        static let settingsExpandAnimationSpringDamping: CGFloat     = 0.9
        static let settingsContractAnimationSpringDamping: CGFloat   = 1.0
        static let settingsAnimationInitialVelocity: CGFloat         = 14.0
        static let dimOverlayEntranceAnimationDuration: TimeInterval = 0.3
        static let dimOverlayExitAnimationDuration: TimeInterval     = 0.1
        static let dimOverlayColor: UIColor                          = UIColor.black.withAlphaComponent(0.3)
        static let hideInterfaceAnimationDuration: TimeInterval      = 0.1
        static let instructionsLabelTextOneWinner: String            = "Place two or more fingers on the screen. After three seconds, one is randomly chosen!"
        static let instructionsLabelTextTwoWinners: String           = "Place two or more fingers on the screen. After three seconds, two are randomly chosen!"
        static let instructionsLabelTextThreeWinners: String         = "Place two or more fingers on the screen. After three seconds, three are randomly chosen!"
        static let instructionsLabelTextFourWinners: String          = "Place two or more fingers on the screen. After three seconds, four are randomly chosen!"
        static let instructionsLabelFont: UIFont                     = .tondo(weight: .regular, size: 17)
        static let instructionsLabelTextColor: UIColor               = .white
        static let instructionsLabelWidth: CGFloat                   = 258.0
        static let instructionsLabelHeight: CGFloat                  = 63.0
        static let instructionsLabelVerticalOffset: CGFloat          = -55.0
        static let separatorBarWidth: CGFloat                        = 258.0
        static let separatorBarHeight: CGFloat                       = 1.0
        static let separatorBarColor: UIColor                        = .white
        static let separatorBarVerticalOffset: CGFloat               = -10.0
        static let titleText: String                                 = "CHOOSER"
        static let titleTextColor: UIColor                           = .white
        static let titleFont: UIFont                                 = .tondo(weight: .bold, size: 54)
        static let titleVerticalOffset: CGFloat                      = -10.0
    }
    
    // MARK: - Public Members
    
    /// Sets the current background gradient to the given background gradient.
    /// This function is public becuse the settings menu interacts with it directly.
    ///
    /// - Parameters:
    ///     - newGradient: The gradient the background will transition to.
    public func setBackgroundGradient(_ newGradient: BackgroundGradient) {
        gradient.colors = newGradient.colors.map({$0.cgColor})
    }
    
    
    /// Sets the text of the instructions label. The text will be different
    /// depending on how many winner there are.
    ///
    /// - Parameters:
    ///     - numWinners: The number of winners the text should reflect.
    public func updateInstructionsLabel(forNumberOfWinners numWinners: Int) {
        switch numWinners {
        case 1: instructionsLabel.text = Constants.instructionsLabelTextOneWinner
        case 2: instructionsLabel.text = Constants.instructionsLabelTextTwoWinners
        case 3: instructionsLabel.text = Constants.instructionsLabelTextThreeWinners
        case 4: instructionsLabel.text = Constants.instructionsLabelTextFourWinners
        default: () // Will never be reached.
        }
    }
    
    // MARK: - Lifecycle

    /// Called when this view controller is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isMultipleTouchEnabled = true
        view.layer.addSublayer(gradient)
        configureGradientBackground(size: UIScreen.main.bounds.size)
        configureSettingsViewController()
        configureInstructionsLabel()
        configureSeparatorLine()
        configureTitleLabel()
        configureAudioPlayers()
    }
    
    @available(iOS 13.0, *)
    override var editingInteractionConfiguration: UIEditingInteractionConfiguration {
        return .none
    }
    
    /// Called when this view appears after it is loaded into memory. 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        promptForReview()
    }
    
    /// Called when the device is rotated. This is needed because the gradient
    /// background, being a CAGradientLayer, does not automatically change frame
    /// size upon rotation.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        configureGradientBackground(size: size)
        if dimOverlayButtonShouldBeVisible() {
            updateDimOverlayButtonDimensions(forViewWithSize: size)
        }
    }
    
    /// We use this to identify when the window size changes enough that we need to modify our user interface.
    /// The only thing that needs modification is the expanded state of the settings menu. Depending on the size
    /// of the window the expanded settings menu will fill just part of the screen, or fill the entire screen.
    /// If it fills the enture screen there is not border, etc.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        toggleSettingsViewBorder(animated: false)
        if dimOverlayButtonShouldBeVisible() {
            updateDimOverlayButtonDimensions(forViewWithSize: view.bounds.size)
            toggleDimOverlayButton(true, animated: false)
        } else {
            toggleDimOverlayButton(false, animated: false)
        }
        if settingsViewController.state == .menu {
            toggleSettingsConstraints(false)
            settingsViewTopConstraint     = getSettingsViewConstraint(constraint: .top, forState: .menu)
            settingsViewBottomConstraint  = getSettingsViewConstraint(constraint: .bottom, forState: .menu)
            settingsViewWidthConstraint   = getSettingsViewConstraint(constraint: .width, forState: .menu)
            settingsViewCenterXConstraint = getSettingsViewConstraint(constraint: .centerX, forState: .menu)
            toggleSettingsConstraints(true)
        }
    }
    
    // MARK: - Title Label
    
    /// Adds and creates the title label.
    private func configureTitleLabel() {
        titleLabel.text = Constants.titleText
        titleLabel.font = Constants.titleFont
        titleLabel.textColor = Constants.titleTextColor
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: seperatorLineView.topAnchor,
                                                      constant: Constants.titleVerticalOffset)
        ])
    }
    
    // MARK: - Separator Line
    
    /// Adds and creates the separator bar.
    private func configureSeparatorLine() {
        seperatorLineView.backgroundColor = Constants.separatorBarColor
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorLineView)
        NSLayoutConstraint.activate([
            seperatorLineView.widthAnchor.constraint(equalToConstant: Constants.separatorBarWidth),
            seperatorLineView.heightAnchor.constraint(equalToConstant: Constants.separatorBarHeight),
            seperatorLineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            seperatorLineView.bottomAnchor.constraint(equalTo: instructionsLabel.topAnchor,
                                                      constant: Constants.separatorBarVerticalOffset)
        ])
    }
    
    // MARK: - Instructions Label
    
    /// Adds and creates the instructions label. 
    private func configureInstructionsLabel() {
        updateInstructionsLabel(forNumberOfWinners: UserPreferences.numberOfWinners)
        instructionsLabel.font = Constants.instructionsLabelFont
        instructionsLabel.textColor = Constants.instructionsLabelTextColor
        instructionsLabel.numberOfLines = 3
        instructionsLabel.textAlignment = .center
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionsLabel)
        NSLayoutConstraint.activate([
            instructionsLabel.widthAnchor.constraint(equalToConstant: Constants.instructionsLabelWidth),
            instructionsLabel.heightAnchor.constraint(equalToConstant: Constants.instructionsLabelHeight),
            instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.bottomAnchor.constraint(equalTo: settingsViewController.view.topAnchor,
                                                      constant: Constants.instructionsLabelVerticalOffset)
        ])
    }
    
    // MARK: - Settings
    
    /// Called in viewDidLoad. Sets up the inital constraints
    /// for the settings button and adds it to the screen.
    public func configureSettingsViewController() {
        settingsViewController = SettingsViewController(mainViewController: self)
        settingsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsViewController.view)
        settingsViewTopConstraint     = getSettingsViewConstraint(constraint: .top, forState: .button)
        settingsViewBottomConstraint  = getSettingsViewConstraint(constraint: .bottom, forState: .button)
        settingsViewWidthConstraint   = getSettingsViewConstraint(constraint: .width, forState: .button)
        settingsViewCenterXConstraint = getSettingsViewConstraint(constraint: .centerX, forState: .button)
        toggleSettingsConstraints(true)
        toggleSettingsViewBorder(animated: false)
    }
    
    /// Called by the settings view controller itself.
    /// The settings view controller tells this class if
    /// the user has tapped it so this class can take action
    /// on either expanding or contracting it.
    ///
    /// - Parameters:
    ///     - state: The state that this class should animate the settings view controller to fit.
    public func settingsViewDidUpdateState(toState state: SettingsViewController.State) {

        toggleSettingsViewBorder(animated: true)
        
        if dimOverlayButtonShouldBeVisible() {
            updateDimOverlayButtonDimensions(forViewWithSize: view.bounds.size)
            toggleDimOverlayButton(true, animated: true)
        } else {
            toggleDimOverlayButton(false, animated: true)
        }
        
        toggleSettingsConstraints(false)
        settingsViewTopConstraint     = getSettingsViewConstraint(constraint: .top, forState: state)
        settingsViewBottomConstraint  = getSettingsViewConstraint(constraint: .bottom, forState: state)
        settingsViewWidthConstraint   = getSettingsViewConstraint(constraint: .width, forState: state)
        settingsViewCenterXConstraint = getSettingsViewConstraint(constraint: .centerX, forState: state)
        toggleSettingsConstraints(true)
        
        toggleUserInterfaceElements(state == .button, includingSettings: false)
        
        UIView.animate(withDuration: Constants.settingsAnimationDuration,
                       delay: .zero,
                       usingSpringWithDamping: state == .button ? Constants.settingsContractAnimationSpringDamping : Constants.settingsExpandAnimationSpringDamping,
                       initialSpringVelocity: Constants.settingsAnimationInitialVelocity,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
        })
    }
    
    /// Whenever we modify the constraints on the settings view controller
    /// we have to briefly turn them on then off.
    /// We do this so much we grated a helper function to do so.
    ///
    /// - Parameters:
    ///     - onOff: A boolean representing if the constraints should be active or not.
    private func toggleSettingsConstraints(_ onOff: Bool) {
        settingsViewTopConstraint.isActive     = onOff
        settingsViewBottomConstraint.isActive  = onOff
        settingsViewWidthConstraint.isActive   = onOff
        settingsViewCenterXConstraint.isActive = onOff
    }
    
    
    /// The settings view controller has three distinct sets of constraints that are different.
    /// If the settings menu is in button form,
    /// we constrain it just below the center of the screen itself.
    ///
    /// If the settings meny is in expanded form, we will constrain
    /// it to be either a form sheet or we will constrain it to fill the entire screen.
    ///
    /// We need this function that will return the correct constraint
    /// for the given state because we modify the constraints every time
    /// the window size changes and every time the settings menu is expanded.
    /// This is quite a bit of modification so this method really cleans up the code.
    ///
    /// - Parameters:
    ///     - constraint: The constraint in which we would like to generate.
    ///     - state: The state in which we would like to generate the constraint for.
    ///
    /// - Returns:
    ///     The NSLayoutConstraint cooresponding with the given constraint and state.
    private func getSettingsViewConstraint(constraint: SettingsConstraints, forState state: SettingsViewController.State) -> NSLayoutConstraint {
        if state == .button {
            let offset = Constants.settingsButtonVerticalOffset
            let width = SettingsViewController.Constants.Dimensions.titleButtonWidth
            let height = SettingsViewController.Constants.Dimensions.titleButtonHeight
            switch constraint {
            case .top:     return settingsViewController.view.topAnchor.constraint(equalTo: view.centerYAnchor, constant: offset)
            case .bottom:  return settingsViewController.view.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: offset + height)
            case .width:   return settingsViewController.view.widthAnchor.constraint(equalToConstant: width)
            case .centerX: return settingsViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            }
        } else {
            if traitCollection.horizontalSizeClass == .compact || traitCollection.verticalSizeClass == .compact {
                switch constraint {
                case .top:     return settingsViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: view.safeAreaInsets.top)
                case .bottom:  return settingsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                case .width:   return settingsViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor)
                case .centerX: return settingsViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                }
            } else {
                let width = Constants.formSheetWindowWidth
                let height = Constants.formSheetWindowHeight
                switch constraint {
                case .top:     return settingsViewController.view.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -height/2)
                case .bottom:  return settingsViewController.view.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: height/2)
                case .width:   return settingsViewController.view.widthAnchor.constraint(equalToConstant: width)
                case .centerX: return settingsViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                }
            }
        }
    }
    
    /// The only time the dim overlay button should be seen is when
    /// the settings menu is expanded and neither the vertical or
    /// horizontal size classes are compact. This really only
    /// happens on an iPad. However, we need to check for this
    /// so much that I made a function to do so to clean up the code.
    ///
    /// - Returns:
    ///     True if the dim overlay button should be visible. False otherwise.
    private func dimOverlayButtonShouldBeVisible() -> Bool {
        return settingsViewController.state == .menu
            && traitCollection.verticalSizeClass != .compact
            && traitCollection.horizontalSizeClass != .compact
    }
    
    /// The dim overlay button is a little strange.
    /// To make it appear behind the settings menu we actually
    /// create a mask that is the size of the settings menu
    /// itself and then cut it out of the dim overlay button.
    /// This means that whenever the window size changes we
    /// have to completely reparameterize the button.
    ///
    /// - Parameters:
    ///     - size: The new window size the button will adapt to.
    private func updateDimOverlayButtonDimensions(forViewWithSize size: CGSize) {
        let cutoutRect = CGRect(x: size.width/2 - Constants.formSheetWindowWidth/2,
                                y: size.height/2 - Constants.formSheetWindowHeight/2,
                                width: Constants.formSheetWindowWidth,
                                height: Constants.formSheetWindowHeight)
        let mutablePath = CGMutablePath()
        mutablePath.addRect(CGRect(origin: .zero, size: size))
        mutablePath.addRoundedRect(in: cutoutRect,
                                   cornerWidth: SettingsViewController.Constants.Dimensions.cornerRadius,
                                   cornerHeight: SettingsViewController.Constants.Dimensions.cornerRadius)
        let mask = CAShapeLayer()
        mask.path = mutablePath
        mask.fillRule = CAShapeLayerFillRule.evenOdd
        dimOverlayButton.layer.mask = mask
        dimOverlayButton.frame = CGRect(origin: .zero, size: size)
        dimOverlayButton.isUserInteractionEnabled = true
        dimOverlayButton.backgroundColor = Constants.dimOverlayColor
        dimOverlayButton.addTarget(settingsViewController,
                                   action: #selector(settingsViewController.dismissPressed),
                                   for: .touchUpInside)
    }
        
    /// When the settings view controller is expanded and neither the vertical
    /// or horizontal size classes are compact, we add a dark dim
    /// background behing the settings menu. This background is a
    /// button so when it is tapped the settings retracts back into button form.
    ///
    /// - Parameters:
    ///     - onOff: A boolean representing if the the dim background should be added or removed.
    ///     - animated: A boolean representing if the onOff transition should happen instanously or be animated.
    private func toggleDimOverlayButton(_ onOff: Bool, animated: Bool) {
        if onOff {
            view.insertSubview(dimOverlayButton, belowSubview: settingsViewController.view)
            if animated {
                dimOverlayButton.alpha = 0.0
                UIView.animate(withDuration: Constants.dimOverlayEntranceAnimationDuration,
                               delay: Constants.settingsAnimationDuration,
                               options: .curveEaseOut,
                               animations: {
                                self.dimOverlayButton.alpha = 1.0
                })
            } else {
                dimOverlayButton.alpha = 1.0
            }
        } else {
            if animated {
                UIView.animate(withDuration: Constants.dimOverlayExitAnimationDuration,
                               delay: 0.0,
                               options: .curveEaseOut,
                               animations: {
                                self.dimOverlayButton.alpha = 0.0
                }) { _ in
                    self.dimOverlayButton.removeFromSuperview()
                }
            } else {
                dimOverlayButton.removeFromSuperview()
            }
        }
    }
    
    /// The settings view controller is collapsed in its entirety
    /// into a the small button in the middle of the screen.
    /// That button has a border - however, the expanded version
    /// of the settings menu does not always have a border.
    /// On the iPhone the expanded settings menu never has a border.
    /// On the iPad, the expanded settings menu only has a
    /// border if the window size of the app is neither vertically
    /// or horizontally compact. The border is needed for the expanded
    /// settings menu in that case because the menu does not fill the full screen.
    ///
    /// - Parameters:
    ///     - animated: A boolean representing if the border will animate as it appears or disappears.
    private func toggleSettingsViewBorder(animated: Bool) {
        
        let isCompact = traitCollection.verticalSizeClass == .compact || traitCollection.horizontalSizeClass == .compact
        let noBorder = settingsViewController.state == .menu && isCompact
        
        if animated {
            UIView.animate(withDuration: Constants.settingsAnimationDuration) {
                self.toggleSettingsViewBorder(animated: false)
            }
        } else {
            settingsViewController.view.layer.borderColor = Constants.settingsBorderColor.cgColor
            settingsViewController.view.layer.borderWidth = noBorder ? 0.0 : Constants.settingsBorderWidth
        }
    }

    // MARK: - Gradient Background
    
    /// This sets the position, size, and colors of the CAGradientLayer we use
    /// to display the background gradient. This has a size parameter becuase
    /// we need to refresh the size when the user rotates the device. Initially,
    /// the size is just set to the main screens' bounds' size.
    ///
    /// - Parameters:
    ///     - size: The CGSize that is the size of the gradient layer's frame.
    private func configureGradientBackground(size: CGSize) {
        setBackgroundGradient(UserPreferences.backgroundGradient)
        gradient.frame.origin = .zero
        gradient.frame.size   = size
    }


    // MARK: - Custom Touch Handling

    /// Called whenever a user places a finger on the screen. This creates a
    /// circle and assigns that circle to the new touch that just occured.
    /// If there is a coundown in process it is stopped and restarted. However,
    /// it is only restarted if there are two or more fingers on the screen. When
    /// there are fingers on the screen the title, seperator, instrucitons, and
    /// settings button are all hidden.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            createCircle(forTouch: touch)
            stopCountdown()
            if shouldStartCountdown() { startCountdown() }
            toggleInterfaceElementsIfNeeded()
        }
    }
    
    /// Called when a finger is moving on the screen.
    /// Each touches circle has its positiion updated
    /// to match the new position of the touch.
    /// This is called hundreds of times per second.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            moveCircle(forTouch: touch)
        }
    }
    
    /// Called when a user lifts their finger from the screen.
    /// This removes the circle associated with their touch.
    /// If there is a countdown in process it is stopped.
    /// Then, if there are two or more fingers remaining on
    /// the screen a countdown is restarted.
    /// When there are no fingers on the screen the title,
    /// seperator, instructions, and settings button reappear. */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            removeCircle(forTouch: touch)
            stopCountdown()
            if shouldStartCountdown() { startCountdown() }
            toggleInterfaceElementsIfNeeded()
        }
    }
    
    ///  This is called when the user recieves a phone call,
    ///  switches apps, etc. If the touches on the screen have
    ///  to be cancelled everyone one of those touches
    ///  is 'ended'. So, we just call the touches ended function.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    // MARK: - Toggling User Interface Elements
    /// Called whenever a circle is added or removed from the screen.
    /// If there are any touches on the screen the title, seperator,
    /// instructions, and settings button are hidden.
    /// Otherwise, they are shown.
    private func toggleInterfaceElementsIfNeeded() {
        toggleUserInterfaceElements(!shouldHideUserInterfaceElements(), includingSettings: true)
    }
    
    /// Used to check if the user interface elements should be hidden or not.
    ///
    /// - Returns:
    ///     True if there are any fingers touching the screen.
    private func shouldHideUserInterfaceElements() -> Bool {
        return circles.count > 0
    }
    
    
    /// Called when a user touches the screen and creates a circle,
    /// when the last circle is removed frm the screen,
    /// and when the settings button is pressed.
    /// This shows or hides the title label, seperator bar, and information text.
    /// Sometimes the settings button is also hidden.
    ///
    /// - Parameters:
    ///     - onOff: A boolean representing the visibility of the user interface elements.
    ///     - includingSettings: A boolean representing the inclusion of the settings button in the toggled elements.
    private func toggleUserInterfaceElements(_ onOff: Bool, includingSettings: Bool) {
        UIView.animate(withDuration: Constants.hideInterfaceAnimationDuration,
                       delay: 0.0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.titleLabel.alpha        = onOff ? 1.0 : 0.0
                        self.seperatorLineView.alpha = onOff ? 1.0 : 0.0
                        self.instructionsLabel.alpha = onOff ? 1.0 : 0.0
                        if includingSettings {
                            self.settingsViewController.view.alpha = onOff ? 1.0 : 0.0
                        }
        })
    }
    
    // MARK: - Circle Mutation
    
    /// Called when a user touches the screen. A circle is created
    /// and placed at the exact location the touch given in the parameter occurs.
    ///
    /// - Parameters:
    ///     - touch: The UITouch corresponding with circle that will be created.
    private func createCircle(forTouch touch: UITouch) {
        let circle = CircleView(color: Constants.circleColor)
        circle.delegate = self
        circle.center   = touch.location(in: view)
        circles[touch]  = circle
        view.addSubview(circle)
        circle.animateEntrance()
        if UserPreferences.vibrations {
            UIImpactFeedbackGenerator.init(style: .heavy).impactOccurred()
        }
        if UserPreferences.sounds {
            playPopSound()
        }
    }
    
    
    var i: CGSize? = nil
    
    /// Called when a user moves their finger around the screen.
    /// The circle for the given touch is found, then the center of
    /// that circle is set to the position of the touch.
    /// This may be called hundreds of times per second.
    ///
    /// - Parameters:
    ///     - touch: The UITouch corresponding with circle that will be moved.
    private func moveCircle(forTouch touch: UITouch) {
        circles[touch]?.center = touch.location(in: view)
    }
    
    /// Called when a user lifts their finger from the screen.
    /// The circle associated with that touch is removed
    /// from the screen and the circles dictionary.
    ///
    /// - Parameters:
    ///     - touch: The UITouch corresponding with circle that will be removed.
    private func removeCircle(forTouch touch: UITouch) {
        circles[touch]?.animateExit()
        circles.removeValue(forKey: touch)
        if UserPreferences.sounds && !winnerExists() {
            playSwooshSound()
        }
    }
    
    // MARK: - Countdown
    
    /// Used to check if a countdown should be started.
    ///
    /// - Returns:
    ///     True if there are enough fingers on the screen for a countdown to start. False otherwise.
    private func shouldStartCountdown() -> Bool {
        return circles.count > UserPreferences.numberOfWinners
    }
    
    /// Stops the countdown timer and resets the count.
    private func stopCountdown() {
        countdown?.invalidate()
        currCount = 0
    }
    
    /// If enough fingers are on the screen this starts the countdown.
    /// The countdown timer is initialized and put on repeat.
    private func startCountdown() {
        if shouldStartCountdown() {
            countdown = Timer.scheduledTimer(timeInterval: Constants.countDuration,
                                             target: self,
                                             selector: #selector(handleCountdown),
                                             userInfo: nil,
                                             repeats: true)
        }
    }
    
    /// Called every time the countdown timer ticks.
    /// The current count is increased and the circles are pulsed.
    /// Once the current count reaches the maximum number of
    /// counts the countdown is stopped and a winner is selected.
    ///
    /// - Parameters:
    ///     - sender: The Timer object that calls this handler.
    @objc private func handleCountdown(_ sender: Timer) {
        if currCount == Constants.maxCount {
            stopCountdown()
            selectWinner()
        } else {
            currCount += 1
            circles.values.forEach({$0.animatePulse()})
            if UserPreferences.vibrations {
                if UserPreferences.vibrations {
                    UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
                }
            }
        }
    }
    
    // MARK: - Winner Selection
    
    /// Called when a countdown has completed. The correct number of winners is chosen.
    private func selectWinner() {
        
        
        
        // We record that a winner was chosen in the user statistics.
        UserStatistics.timesChosen += 1
        
        // When a winner is selected no new touches should be registered
        // until the winner's finger is removed from the screen.
        view.isUserInteractionEnabled = false
        
        // An array will be filled with random circles. One for each winner.
        var winners = [CircleView]()
        
        var numToChoose = UserPreferences.numberOfWinners
        
        if numToChoose > circles.count {
            numToChoose = circles.count
        }
        
        while winners.count < numToChoose {
            let winner = circles.values.randomElement()!
            if !winners.contains(winner) {
                winners.append(winner)
            }
        }
        
        // All the winning circles are expanded and the others are removed.
        for (touch, circle) in circles {
            if UserPreferences.vibrations {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            if winners.contains(circle) {
                circle.animateWin()
            } else {
                removeCircle(forTouch: touch)
            }
        }
        
        if UserPreferences.sounds {
            playWinnerSound()
        }
    }
    
    // MARK: - Review Promt
    
    /// Called after the winner is selected. If the user has used
    /// the app more than three times, they are prompted for a review.
    /// The prompt does not always show. It only shows when apple feels like it.
    /// Something like once or twice a year idk.
    private func promptForReview() {
        if #available(iOS 10.3,*){
            if UserStatistics.timesChosen >= 3 {
                SKStoreReviewController.requestReview()
            }
        }
    }

    // MARK: - Sound Effects
    
    /// Called when a finger is placed on the screen. A random pop sound is played.
    private func playPopSound() {
        let pops: [SoundEffect] = [.Pop1,.Pop2,.Pop3,.Pop4,.Pop5,.Pop6]
        playSound(pops.randomElement()!)
    }
    
    /// Called when a finger is removed from the screen. A random swoosh sound is played.
    private func playSwooshSound() {
        let swooshes: [SoundEffect] = [.Swoosh1,.Swoosh2,.Swoosh3,.Swoosh4,.Swoosh5,.Swoosh6]
        playSound(swooshes.randomElement()!)
    }
    
    /// Called when a winner is chosen. A short winning sound is played.
    private func playWinnerSound() {
        playSound(.Winner)
    }
    
    /// Called in the view did load function. Every sound effect gets and audio player that is generated and
    /// preapred for playing later. This is needed because if we do not prpare the audio players, sound will
    /// be delayed.
    private func configureAudioPlayers() {
        for soundEffect in SoundEffect.allCases {
            if let soundURL = Bundle.main.url(forResource: soundEffect.resourceName, withExtension: "mp3") {
                do {
                    audioPlayers[soundEffect] =  try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayers[soundEffect]?.prepareToPlay()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    /// Playes the given sound effect.
    ///
    /// - Parameters:
    ///     - soundEffect: The SoundEffect representing the sound intended to be played.
    private func playSound(_ soundEffect: SoundEffect) {
        DispatchQueue.global(qos: .background).async {
            self.audioPlayers[soundEffect]?.play()
        }
    }
    
    /// Called when the swoosh sound is about to play. If any circle is a winner
    /// then the swoosh sound is NOT played. This is the only time this method is
    /// currently used. 
    private func winnerExists() -> Bool {
        return circles.values.filter({$0.isWinner}).count > 0
    }
}


// MARK: - UICircleDelegate

extension ChooserViewController: UICircleDelegate {
    
    /// Called when a circle is removed from the screen. If the circle was a winner all circles are removed from the screen.
    ///
    /// - Parameters:
    ///     - circle: The UICircleView communicating with this delegate class.
    ///     - wasWinner: A boolean indicating whether the removed circle was a winner or not.
    func circle(_ circle: CircleView, didRemoveFromSuperview wasWinner: Bool) {
        if wasWinner && circles.count == 0 {
            circles.removeAll()
            view.isUserInteractionEnabled = true
        }
    }
    
    /// Used to pass the information of the countdown duration to the Circle's themselves.
    /// They need this so they can time their pulse animation properly.
    ///
    /// - Parameters:
    ///     - circle: The UICircleView communicating with this delegate class.
    ///
    /// - Returns:
    ///     The TimeInterval in which a count occurs.
    func circleSetPulseTime(_ circle: CircleView) -> TimeInterval {
        return Constants.countDuration
    }
    
}



