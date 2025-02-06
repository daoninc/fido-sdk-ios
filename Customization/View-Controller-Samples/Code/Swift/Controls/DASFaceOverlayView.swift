//
//  DASFaceOverlayView.swift
//  DaonAuthenticatorSDK
//
//  Created by Neil Johnston on 9/6/18.
//  Copyright © 2018 Daon. All rights reserved.
//

import DaonAuthenticatorFace
import DaonAuthenticatorSDK


/*!
@brief Face overlay.
*/
class DASFaceOverlayView: UIView {
    

    enum OvalType {
        case ellipse
        case face
    }

    
    /*!
     @brief The calculated distance between the top of the ellipse and the top of the view.
     */
    public var topDistanceToViewArea : CGFloat = 0.0
    
    /*!
     @brief The calculated distance between the bottom of the ellipse and the bottom of the view.
     */
    public var bottomDistanceToViewArea : CGFloat = 0.0
    
    /*!
     @brief Background gradient.
     */
    private var backgroundLayer : CAGradientLayer?
    
    /*!
     @brief Layer to draw a border around where the user should put their face.
     */
    private var ellipseBorderLayer : CAShapeLayer?
    
    /*!
     @brief Layer used as a mask on the backgroundLayer.
     */
    private var maskLayer : CAShapeLayer?
        
    /*!
     @brief Message label.
     */
    private var messageLabel : UILabel?

    /*!
     @brief Warning message label.
     */
    private var warningLabel : UILabel?

    /*!
     @brief Result imageview.
     */
    private var resultImageView : UIImageView?
    
    /*!
     @brief How much padding to put around the message label within the ellipse.
     */
    private let labelPadding: CGFloat = 20.0
        
    private var scale: CGFloat = 1.0
    
    private var type: OvalType = OvalType.ellipse
    
    
    /*!
     @brief Initializes the view with a frame. Here we add the background gradient, overlay mask and message label.
     @param frame The initial frame for the view.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        self.backgroundLayer = CAGradientLayer()
        
        if (DASUtils.isDarkModeEnabled()) {
            self.backgroundLayer!.colors = [UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor,
                                            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 76.0/255.0).cgColor,
                                            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor]
        } else {
            self.backgroundLayer!.colors = [UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor,
                                            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 76.0/255.0).cgColor,
                                            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor]
        }
        
        self.backgroundLayer!.startPoint    = CGPoint(x: 0.5, y: 1)
        self.backgroundLayer!.endPoint      = CGPoint(x: 0.5, y: 0);
        
        self.maskLayer = CAShapeLayer()
        self.maskLayer!.fillRule = CAShapeLayerFillRule.evenOdd
        
        self.backgroundLayer!.mask = self.maskLayer!
        
        self.layer.addSublayer(self.backgroundLayer!)
        
        // Border around ellipse
        self.ellipseBorderLayer                 = CAShapeLayer()
        self.ellipseBorderLayer!.fillColor      = UIColor.clear.cgColor
        self.ellipseBorderLayer!.strokeColor    = UIColor.gray.cgColor
        self.ellipseBorderLayer!.lineWidth      = 5
        self.layer.addSublayer(self.ellipseBorderLayer!)
        
        // Message Label
        self.messageLabel                   = UILabel()
        self.messageLabel?.textAlignment    = .center
        self.messageLabel?.numberOfLines    = 0
        self.messageLabel?.lineBreakMode    = .byWordWrapping
        self.messageLabel?.font             = UIFont.boldSystemFont(ofSize: 32)
        self.messageLabel?.shadowColor      = .black
        self.messageLabel?.shadowOffset     = CGSize(width: 1, height: 1)
        self.messageLabel?.textColor        = .white
        self.addSubview(self.messageLabel!)
        
        self.warningLabel                   = UILabel()
        self.warningLabel?.textAlignment    = .center
        self.warningLabel?.numberOfLines    = 2
        self.warningLabel?.lineBreakMode    = .byWordWrapping
        self.warningLabel?.textColor        = .red
        self.warningLabel?.adjustsFontSizeToFitWidth = true
        self.addSubview(self.warningLabel!)
        
        // Result image view
        self.resultImageView                    = UIImageView()
        self.resultImageView?.contentMode       = .scaleAspectFit
        self.resultImageView?.backgroundColor   = .clear
        self.resultImageView?.clipsToBounds     = true
        self.addSubview(self.resultImageView!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    /*!
     @brief Sets the final sizes for the dynamically added UI elements.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundLayer!.frame = self.bounds
        self.messageLabel?.frame    = self.bounds
        
        let outerPath = UIBezierPath(rect: self.bounds)
        
        let side =  CGFloat.minimum(self.bounds.size.width, self.bounds.size.height) * 0.7 * scale
        let circleRect = CGRect(x: self.bounds.size.width/2 - side/2,
                                y: (self.bounds.height - (self.bounds.height * 0.55 * scale)) / 2,
                                width: side,
                                height: self.bounds.height * 0.55 * scale)
        
        let ovalPath = type == .face ? faceOvalBezierPath() : UIBezierPath(ovalIn: circleRect)
        outerPath.usesEvenOddFillRule = true
        outerPath.append(ovalPath)

        self.topDistanceToViewArea      = circleRect.origin.y
        self.bottomDistanceToViewArea   = self.bounds.maxY - circleRect.maxY
        
        self.maskLayer!.frame = self.bounds
        self.maskLayer!.path = outerPath.cgPath
        
        self.ellipseBorderLayer!.frame = self.bounds
        self.ellipseBorderLayer!.path =  ovalPath.cgPath
        
        self.messageLabel?.frame = CGRect(x: circleRect.origin.x + labelPadding,
                                          y: circleRect.origin.y + labelPadding,
                                          width: circleRect.size.width - (labelPadding * 2),
                                          height: circleRect.size.height - (labelPadding * 2))
        
        self.warningLabel?.frame = CGRect(x: self.bounds.origin.x + labelPadding,
                                          y: circleRect.maxY,
                                          width: self.bounds.size.width - (labelPadding * 2),
                                          height: 100)
        
        self.resultImageView?.frame = CGRect(x: self.center.x - 16,
                                             y: self.center.y - 16,
                                             width: 32,
                                             height: 32);
    }
    
    func oval(type: OvalType) {
        self.type = type
        setNeedsLayout()
    }
    
    func oval(color: UIColor) {
        ellipseBorderLayer!.strokeColor = color.cgColor
    }
    
    func resize(scale: CGFloat) {
        self.scale = scale
        setNeedsLayout()
    }

    func animate(from: CGFloat, to: CGFloat, duration: TimeInterval) {

        self.transform = CGAffineTransform(scaleX: from, y: from)
        UIView.animate(withDuration: duration, animations: {() -> Void in
            self.transform = CGAffineTransform(scaleX: to, y: to)
        })
    }
   
    
    func animate(to: CGFloat, duration: TimeInterval) {

        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = to
        animation.duration = duration
        
        ellipseBorderLayer!.add(animation, forKey: nil)
        maskLayer!.add(animation, forKey: nil)
    }
    
    /*!
     @brief Handles the analysis result of a processed frame.
     @param passed YES if the image frame passed our quality checks. An image passes if the device is upright AND the image quality score is >= the global score threshold AND the image has acceptable eye distance.
     @param issues If passed is NO, then this will provide a list of any quality issues (DASAuthenticatorError in NSNumber) detected.
     */
    func update(quality: Bool, issues: [NSNumber]?) {
        
        if quality {
            ellipseBorderLayer!.strokeColor = UIColor.green.cgColor
        } else {
            ellipseBorderLayer!.strokeColor = UIColor.gray.cgColor
        }
        
        if let firstIssue = issues?.first {
            if let error = DASAuthenticatorError(rawValue: firstIssue.intValue) {
                    if let errorString = DASUtils.string(forError: error) {
                        update(message: errorString)
                    }
            }
        } else {
            update(message: nil)
        }
    }
    
    
    /*!
     @brief Displays a status / instructional message.
     @param message The message to display.
     */
    func update(message: String?) {
        update(message: message, color: .white)
    }

    /*!
     @brief Displays a status / instructional message.
     @param message The message to display.
     @param color The color
     */
    func update(message: String?, color: UIColor) {
        DispatchQueue.main.async {
            self.messageLabel?.text = message
            self.messageLabel?.textColor = color
        }
    }
    
    /*!
     @brief Displays a status / instructional message.
     @param message The message to display.
     */
    func update(status: String) {
        print("STATUS: ", status)
    }
    
    
    /*!
     @brief Displays a more permanent warning message.
     @param warning The warning to display.
     */
    func update(warning: String, color: UIColor) {
        DispatchQueue.main.async {
            self.warningLabel?.text = warning
            self.warningLabel?.textColor = color
        }
    }
    
    /*!
    @brief Hide overlay
    */
    func hide() {
        ellipseBorderLayer?.isHidden = true
        maskLayer?.isHidden = true
    }
    
    /*!
    @brief Show overlay
    */
    func show() {
        ellipseBorderLayer?.isHidden = false
        maskLayer?.isHidden = false
    }
    
    /*!
    @brief Displays a passed / failed indicator.
    @param passed The result.
    */
    func update(withResult: Bool) {
        if let imageView = resultImageView {
            imageView.alpha     = 0
            imageView.isHidden  = false
            imageView.image     = (withResult) ? DASUtils.loadImageNamed("Passed-Indicator") : DASUtils.loadImageNamed("Failed-Indicator")
        
            UIView.animate(withDuration: 1) { imageView.alpha = 1 }
        }
    }
    
    /*!
     @brief Clears any visible status / instructional message / result icon.
     */
    func reset() {
        messageLabel?.text          = nil
        resultImageView?.isHidden   = true
    }
    
    private func faceOvalBezierPath() -> UIBezierPath {
        
        let screenWidth = Double(self.bounds.width)
        let radius = screenWidth/3
        let ovalHeight = (2.0 * radius / 257 * 328)
        
        let maxWidth = Int(2.0 * radius)
        let maxHeight = Int(ovalHeight)
        let centerP = Int(screenWidth/2)
        let startPointX = centerP - (maxWidth/2)
        let startPointY = Double(self.center.y) - ovalHeight/2 - 33.5
        
        let frame = CGRect(x: startPointX, y: Int(startPointY), width: maxWidth, height: maxHeight)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.99794 * frame.width, y: frame.minY + 0.53923 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.95587 * frame.width, y: frame.minY + 0.70457 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98420 * frame.width, y: frame.minY + 0.60468 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.97753 * frame.width, y: frame.minY + 0.67994 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.91185 * frame.width, y: frame.minY + 0.72036 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.94548 * frame.width, y: frame.minY + 0.71639 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.92762 * frame.width, y: frame.minY + 0.71991 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.50320 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.85718 * frame.width, y: frame.minY + 0.88244 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.69492 * frame.width, y: frame.minY + 1.00000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.09436 * frame.width, y: frame.minY + 0.71971 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.31149 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.14878 * frame.width, y: frame.minY + 0.88213 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.04494 * frame.width, y: frame.minY + 0.70393 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.07736 * frame.width, y: frame.minY + 0.71971 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.05654 * frame.width, y: frame.minY + 0.71684 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00211 * frame.width, y: frame.minY + 0.53946 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.02289 * frame.width, y: frame.minY + 0.67950 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01611 * frame.width, y: frame.minY + 0.60460 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.04673 * frame.width, y: frame.minY + 0.48409 * frame.height), controlPoint1: CGPoint(x: frame.minX + -0.00765 * frame.width, y: frame.minY + 0.49411 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.01804 * frame.width, y: frame.minY + 0.48435 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.04696 * frame.width, y: frame.minY + 0.48503 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.03627 * frame.width, y: frame.minY + 0.39994 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.03985 * frame.width, y: frame.minY + 0.45699 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.03627 * frame.width, y: frame.minY + 0.42850 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.50312 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.03627 * frame.width, y: frame.minY + 0.17895 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.24528 * frame.width, y: frame.minY + 0.00000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.97005 * frame.width, y: frame.minY + 0.39964 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.76095 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.97005 * frame.width, y: frame.minY + 0.17890 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.97005 * frame.width, y: frame.minY + 0.40000 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.95934 * frame.width, y: frame.minY + 0.48520 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.97005 * frame.width, y: frame.minY + 0.42860 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.96646 * frame.width, y: frame.minY + 0.45713 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.99794 * frame.width, y: frame.minY + 0.53923 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.98551 * frame.width, y: frame.minY + 0.48541 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00685 * frame.width, y: frame.minY + 0.49671 * frame.height))
        
        bezierPath.close()
        
        return bezierPath
      }
}
