//
//  DASCircularLevelMeter.swift
//  DaonAuthenticatorSDK
//
//  Copyright © 2019 Daon. All rights reserved.
//

import UIKit

import DaonAuthenticatorVoice

// Closures

/*!
 @typedef ButtonModeActionBlock
 @brief Block that is used to notify a calling object that the user has pressed the level meter.
 */
typealias ButtonModeActionBlock = () -> Void


// Enums

enum DASCircularLevelMeterState : Int
{
    case ready      = 0
    case active     = 1
    case processing = 2
}


/*!
 @brief A LevelMeter which is used specifically for generic decibel datasources
 */
class DASCircularLevelMeter: UIView
{
    // MARK:- Constants
    private let animationDuration = 0.25
    
    
    // MARK:- Controls
    
    private var backgroundImageView : UIImageView?
    private var staticCircleView: UIView?
    private var dynamicCircleView: UIView?
    private var actionLabel: UILabel?
    private var processingIndicator: UIActivityIndicatorView?
    private var resultImageView: UIImageView?
    
    
    // MARK:- Constraints
    
    private var dynamicViewWidthConstraint: NSLayoutConstraint?
    private var dynamicViewHeightConstraint: NSLayoutConstraint?
    
    
    // MARK:- Button Mode
    
    private var buttonStartText: String?
    private var buttonStopText: String?
    private var buttonAction: ButtonModeActionBlock?
    private var tapGestureRecognizer: UIGestureRecognizer?
    
    
    // MARK:- State
    
    var updateTimer: Timer?
    private var state = DASCircularLevelMeterState.ready
    private var buttonModeEnabled = false
    private var addedLayoutConstraints = false
    private var retryModeEnabled = false
    
    
    // MARK:- Configuration Properties
    
    private unowned var audioMeterDataSourcePrivate: DASAudioMeterDataSource?
    
    /*!
     @brief Delegate object which provides the current audio level for display.
     */
    unowned var audioMeterDataSource : DASAudioMeterDataSource?
    {
        get
        {
            return audioMeterDataSourcePrivate
        }
        set
        {
            if (audioMeterDataSourcePrivate == nil)
            {
                if (updateTimer != nil)
                {
                    updateTimer!.invalidate()
                }
                
                updateTimer = Timer.scheduledTimer(timeInterval: self.refreshHz,
                                                   target: self,
                                                   selector: #selector(refresh),
                                                   userInfo: nil,
                                                   repeats: true)
            }
            
            audioMeterDataSourcePrivate = newValue
        }
    }
    
    /*!
     @brief The time interval between redraws.
     */
    var refreshHz = 1.0 / 30.0
    
    /*!
     @brief The maximum width of the pulse that emanates from the center of the control.
     */
    var maxPulseWidth = 200
    
    /*!
     @brief The color for the control when not recording.
     */
    var inactiveColor = UIColor(red:26/255.0, green:88.0/255.0, blue:130.0/255.0, alpha:1)
    
    /*!
     @brief The color for the control when not recording and the user is pressing it.
     */
    var inactiveSelectedColor = UIColor(red:36/255.0, green:98.0/255.0, blue:140.0/255.0, alpha:1)
    
    /*!
     @brief The color for the control when recording.
     */
    var recordingColor = UIColor(red: 255.0/255.0, green:0, blue:0, alpha:0.75)
    
    /*!
     @brief The color for the recording pulse / level.
     */
    var recordingPulseColor = UIColor(red: 255.0/255.0, green:100.0/255.0, blue:100.0/255.0, alpha:0.75)
    
    /*!
     @brief The color for the control when recording and the user is pressing it.
     */
    var recordingSelectedColor = UIColor.red
    
    /*!
     @brief The color to use for the label when button mode is enabled.
     */
    var actionLabelTextColor = UIColor.white
    
    /*!
     @brief The style of activity indicator to use when button mode is enabled.
     */
    var processingIndicatorStyle : UIActivityIndicatorView.Style
    
    
    // MARK:- Initialisation
    
    required init?(coder aDecoder: NSCoder)
    {
        if #available(iOS 13.0, *)
        {
            processingIndicatorStyle = .large
        }
        else
        {
            processingIndicatorStyle = .whiteLarge
        }
        
        super.init(coder: aDecoder)
        
        // Add gesture recogniser
        self.isUserInteractionEnabled = true
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(actionButtonPressed))
        self.addGestureRecognizer(tapGestureRecognizer!)
        
        // Add the controls
        dynamicCircleView                                               = UIView()
        dynamicCircleView!.translatesAutoresizingMaskIntoConstraints    = false // Ensures we use autolayout
        dynamicCircleView!.isUserInteractionEnabled                     = false
        self.addSubview(dynamicCircleView!)
        
        staticCircleView                                            = UIView()
        staticCircleView!.translatesAutoresizingMaskIntoConstraints = false // Ensures we use autolayout
        staticCircleView!.isUserInteractionEnabled                  = false
        self.addSubview(staticCircleView!)
        
        backgroundImageView                                             = UIImageView()
        backgroundImageView!.image                                      = DASUtils.loadImageNamed("LevelMeterMicrophone")
        backgroundImageView!.contentMode                                = .scaleAspectFit
        backgroundImageView!.translatesAutoresizingMaskIntoConstraints  = false // Ensures we use autolayout
        backgroundImageView!.isUserInteractionEnabled                   = false
        backgroundImageView!.backgroundColor                            = UIColor.clear
        self.addSubview(backgroundImageView!)
        
        actionLabel                                             = UILabel()
        actionLabel!.text                                       = nil;
        actionLabel!.translatesAutoresizingMaskIntoConstraints  = false // Ensures we use autolayout
        actionLabel!.textAlignment                              = .center;
        actionLabel!.font                                       = UIFont.boldSystemFont(ofSize: 22)
        actionLabel!.isUserInteractionEnabled                   = false
        self.addSubview(actionLabel!)
        
        processingIndicator                                             = UIActivityIndicatorView(style: self.processingIndicatorStyle)
        processingIndicator!.isUserInteractionEnabled                   = false
        processingIndicator!.translatesAutoresizingMaskIntoConstraints  = false
        processingIndicator!.color                                      = .white
        self.addSubview(processingIndicator!)
        
        resultImageView                                             = UIImageView()
        resultImageView!.alpha                                      = 0
        resultImageView!.isUserInteractionEnabled                   = false
        resultImageView!.translatesAutoresizingMaskIntoConstraints  = false
        self.addSubview(resultImageView!)
    }
    
    
    // MARK:- Configuration
    
    /*!
     @brief Initialises a new instance using the settings from the server.
     @param startText The text telling the user to press to start recording.
     @param stopText The text telling the user to press to stop recording.
     @param retryModeEnabled Whether or not pressing stop acts as a retry (recording we be restarted).
     @param action A ButtonModeActionBlock block to execute when the level meter is pressed.
     */
    func enableButtonMode(startText: String,
                          stopText: String,
                          retryModeEnabled: Bool,
                          action: @escaping ButtonModeActionBlock)
    {
        self.buttonModeEnabled  = true
        self.buttonStartText    = startText
        self.buttonStopText     = stopText
        self.buttonAction       = action
        self.retryModeEnabled   = retryModeEnabled
        self.actionLabel!.text  = buttonStartText
        
        startStaticCirclePulse()
    }
    
    
    // MARK:- View Lifecycle
    
    override func layoutSubviews()
    {
        if (!addedLayoutConstraints)
        {
            addedLayoutConstraints = true
            
            staticCircleView!.backgroundColor    = self.inactiveColor
            dynamicCircleView!.backgroundColor   = self.recordingPulseColor
            actionLabel!.textColor               = self.actionLabelTextColor
            
            addConstraints(fromView:staticCircleView!, toSuperView:self, addTop:true, addBottom:true, addLeading:true, addTrailing:true, padding:0)
            addConstraints(fromView:resultImageView!, toSuperView:self, addTop:true, addBottom:true, addLeading:true, addTrailing:true, padding:0)
            addCenterConstraints(forSubview: dynamicCircleView!, xOffset: 0, yOffset: 0)
            
            if (buttonModeEnabled)
            {
                addCenterConstraints(forSubview: actionLabel!, xOffset: 0, yOffset: 20)
                addCenterConstraints(forSubview: processingIndicator!, xOffset: 0, yOffset: 0)
                
                backgroundImageView!.addConstraint(createEqualRelationConstraint(forView: backgroundImageView!, attribute: .height, constant: Float(self.frame.size.height / 3))!)
                backgroundImageView!.addConstraint(createEqualRelationConstraint(forView: backgroundImageView!, attribute: .width, constant: Float(self.frame.size.width / 3))!)
                
                addCenterConstraints(forSubview: backgroundImageView!, xOffset: 0, yOffset:Float(-self.frame.size.width / 6))
            }
            else
            {
                addConstraints(fromView:backgroundImageView!, toSuperView:self, addTop:true, addBottom:true, addLeading:true, addTrailing:true, padding:20)
            }
            
            dynamicViewWidthConstraint = createEqualRelationConstraint(forView: dynamicCircleView!, attribute: .width, constant: Float(staticCircleView!.frame.size.width))!
            dynamicViewHeightConstraint = createEqualRelationConstraint(forView: dynamicCircleView!, attribute: .height, constant: Float(staticCircleView!.frame.size.height))!
            dynamicCircleView!.addConstraints([dynamicViewWidthConstraint!, dynamicViewHeightConstraint!])
            
            // Updating the cornerRadius in layoutSubviews, didMoveToSuperview or willMoveToSuperview does not work
            // so we add an async call here to do it after layout completes.
            
            DispatchQueue.main.async
                {
                    self.staticCircleView!.layer.cornerRadius = self.staticCircleView!.bounds.size.width / 2.0
            }
        }
        
        super.layoutSubviews()
    }
    
    
    // MARK:- Touch Events
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (buttonModeEnabled)
        {
            switch (state)
            {
                case .ready:
                    staticCircleView!.backgroundColor = self.inactiveSelectedColor
                    break;
                    
                case .active:
                    staticCircleView!.backgroundColor = self.recordingSelectedColor
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if (buttonModeEnabled)
        {
            switch (state)
            {
                case .ready:
                    staticCircleView!.backgroundColor = self.inactiveColor
                    break;
                    
                case .active:
                    staticCircleView!.backgroundColor = self.recordingColor
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    
    // MARK:- Actions
    
    @objc func actionButtonPressed()
    {
        if (buttonModeEnabled && state != .processing)
        {
            switch (state)
            {
                case .ready:
                    buttonAction?() // Call immediately to reduce button press to recording start time. Then do the UI transition.
                    
                    stopStaticCirclePulse()
                    
                    state                               = .active
                    processingIndicator!.isHidden       = true
                    staticCircleView!.backgroundColor   = self.recordingColor
                    
                    UIView.animate(withDuration: self.animationDuration,
                                   animations: {
                                    self.actionLabel?.alpha = 0
                    }) { (finished) in
                        self.actionLabel?.text = self.buttonStopText
                        
                        UIView.animate(withDuration: self.animationDuration,
                                       animations: { self.actionLabel?.alpha = 1 })
                    }
                    break;
                    
                case .active:
                    if (!retryModeEnabled)
                    {
                        showProcessing()
                    }
                    
                    buttonAction?()
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    /*!
     @brief Move the UI to its success mode. In this mode the start/stop label will disappear and be replaced with a success icon.
     @param reset Whether or not to call reset: after the success state has been displayed for a second.
     */
    func showSuccess(reset: Bool)
    {
        showResult(resultImage: "LevelMeterSuccess", thenReset: reset)
    }
    
    /*!
     @brief Move the UI to its failure mode. In this mode the start/stop label will disappear and be replaced with an error icon.
     @param reset Whether or not to call reset: after the error state has been displayed for a second.
     */
    func showFailure(reset: Bool)
    {
        showResult(resultImage: "LevelMeterFailure", thenReset: reset)
    }
    
    /*!
     @brief Move the UI to its processing mode. In this mode the start/stop label will disappear and be replaced with a UIActivityIndicatorView.
     */
    func showProcessing()
    {
        if (state != .processing)
        {
            state                               = .processing
            processingIndicator!.isHidden       = false
            processingIndicator!.alpha          = 0
            dynamicCircleView!.backgroundColor  = UIColor.clear
            staticCircleView!.backgroundColor   = self.inactiveColor
            
            UIView.animate(withDuration: animationDuration,
                           animations: {
                            self.actionLabel!.alpha          = 0
                            self.backgroundImageView!.alpha  = 0
            }) { (finished) in
                self.actionLabel!.text   = nil
                self.actionLabel!.alpha  = 1
                
                self.processingIndicator!.startAnimating()
                
                UIView.animate(withDuration: self.animationDuration,
                               animations: {
                                self.processingIndicator!.alpha             = 1
                                self.dynamicViewWidthConstraint!.constant   = self.staticCircleView!.frame.size.width
                                self.dynamicViewHeightConstraint!.constant  = self.staticCircleView!.frame.size.height
                })
            }
            
            self.setNeedsDisplay()
        }
    }
    
    /*!
     @brief Determine whether the UI is currently in processing mode (start/stop label is not visible, UIActivityIndicatorView is visible).
     @return YES if the @link processingIndicatorStyle @/link control is visible.
     */
    func isShowingProcessing() -> Bool
    {
        return state == .processing
    }
    
    /*!
     @brief Reset the UI to its original state.
     */
    func reset()
    {
        DispatchQueue.main.async
            {
                self.state                              = .ready
                self.actionLabel!.text                  = self.buttonStartText
                self.processingIndicator!.isHidden      = true
                self.processingIndicator!.alpha         = 1
                self.actionLabel!.alpha                 = 1
                self.backgroundImageView!.alpha         = 1
                self.resultImageView!.alpha             = 0
                self.staticCircleView!.backgroundColor  = self.inactiveColor
                self.dynamicCircleView!.backgroundColor = self.recordingPulseColor
                
                self.updatePulseRadius(Float(self.staticCircleView!.frame.size.width))
                
                self.stopStaticCirclePulse()
                self.startStaticCirclePulse()
        }
        
    }
    
    @objc func refresh()
    {
        if (self.audioMeterDataSource != nil && (!buttonModeEnabled || state == .active))
        {
            let value = self.audioMeterDataSource!.audioMeterLevel()
            
            self.updatePulseRadius(Float(staticCircleView!.bounds.size.width) + (value * Float(self.maxPulseWidth)))
        }
    }
    
    
    // MARK:- Animation
    
    func startStaticCirclePulse()
    {
        //    CABasicAnimation *scaleAnimation    = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        //    scaleAnimation.duration             = 0.5;
        //    scaleAnimation.repeatCount          = HUGE_VAL;
        //    scaleAnimation.autoreverses         = true
        //    scaleAnimation.fromValue            = [NSNumber numberWithFloat:1.0];
        //    scaleAnimation.toValue              = [NSNumber numberWithFloat:1.1];
        //
        //    [staticCircleView.layer addAnimation:scaleAnimation forKey:@"scale"];
    }
    
    func stopStaticCirclePulse()
    {
        //   [staticCircleView.layer removeAnimationForKey:@"scale"];
    }
    
    func updatePulseRadius(_ radius: Float)
    {
        dynamicViewWidthConstraint!.constant    = CGFloat(radius)
        dynamicViewHeightConstraint!.constant   = dynamicViewWidthConstraint!.constant
        dynamicCircleView!.layer.cornerRadius   = dynamicViewWidthConstraint!.constant / 2.0
        
        setNeedsDisplay()
    }
    
    func showResult(resultImage: String, thenReset: Bool)
    {
        resultImageView!.image = DASUtils.loadImageNamed(resultImage)
        
        if (thenReset)
        {
            resultImageView!.alpha   = 0
            actionLabel!.alpha       = 0
            actionLabel!.text        = buttonStartText
            
            UIView.animate(withDuration: 0.5,
                           animations: {
                            self.processingIndicator!.alpha = 0
            }) { (finished) in
                
                UIView.animate(withDuration: 1,
                               animations: {
                                self.resultImageView!.alpha = 1
                                
                                UIView.animate(withDuration: 0.5,
                                               animations: {
                                                self.resultImageView!.alpha = 0
                                },
                                               completion: { (finished) in
                                                
                                                UIView.animate(withDuration: 0.5,
                                                               animations: {
                                                                self.backgroundImageView!.alpha = 1
                                                                self.actionLabel!.alpha         = 1
                                                },
                                                               completion: { (finished) in
                                                                self.reset()
                                                })
                                })
                })
            }
        }
        else
        {
            UIView.animate(withDuration: 0.5,
                           animations: {
                            self.processingIndicator!.alpha = 0
            }) { (finished) in
                self.processingIndicator!.isHidden = true
                
                UIView.animate(withDuration: 0.5,
                               animations: {
                                self.resultImageView!.alpha = 1
                })
            }
        }
    }
    
    
    // MARK:- Autolayout
    
    func addConstraints(fromView: UIView, toSuperView: UIView, addTop: Bool, addBottom: Bool, addLeading: Bool, addTrailing: Bool, padding: CGFloat)
    {
        if (addTop)
        {
            toSuperView.addConstraint(NSLayoutConstraint(item: fromView,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: toSuperView,
                                                         attribute: .top,
                                                         multiplier: 1.0,
                                                         constant: padding))
        }
        
        if (addBottom)
        {
            toSuperView.addConstraint(NSLayoutConstraint(item: fromView,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: toSuperView,
                                                         attribute: .bottom,
                                                         multiplier: 1.0,
                                                         constant: -padding))
        }
        
        if (addLeading)
        {
            toSuperView.addConstraint(NSLayoutConstraint(item: fromView,
                                                         attribute: .leading,
                                                         relatedBy: .equal,
                                                         toItem: toSuperView,
                                                         attribute: .leading,
                                                         multiplier: 1.0,
                                                         constant: padding))
        }
        
        if (addTrailing)
        {
            toSuperView.addConstraint(NSLayoutConstraint(item: fromView,
                                                         attribute: .trailing,
                                                         relatedBy: .equal,
                                                         toItem: toSuperView,
                                                         attribute: .trailing,
                                                         multiplier: 1.0,
                                                         constant: -padding))
        }
    }
    
    func addCenterConstraints(forSubview: UIView, xOffset: Float, yOffset: Float)
    {
        let centerXConstraint = NSLayoutConstraint(item: forSubview,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: CGFloat(xOffset))
        
        let centerYConstraint = NSLayoutConstraint(item: forSubview,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: CGFloat(yOffset))
        
        self.addConstraints([centerXConstraint, centerYConstraint])
    }
    
    func createEqualRelationConstraint(forView: UIView, attribute: NSLayoutConstraint.Attribute, constant: Float) -> NSLayoutConstraint?
    {
        return NSLayoutConstraint(item: forView,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1.0,
                                  constant: CGFloat(constant))
    }
    
    
    // MARK:- Memory Management
    
    deinit
    {
        if (updateTimer != nil)
        {
            updateTimer!.invalidate()
            updateTimer = nil
        }
    }
}

