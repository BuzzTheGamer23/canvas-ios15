//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit
import SVGKit
import React
import Kingfisher

public typealias Props = [String: Any]

protocol HelmScreen {
    var screenConfig: [String: Any] { get set }
    var screenInstanceID: String { get }
    var screenConfigRendered: Bool { get set }
}

class TitleView: UIView {
    public override func willMove(toSuperview: UIView?) {
        if #available(iOS 11.0, *) {
        } else if let parent = toSuperview {
            self.frame = parent.bounds
        }
    }
}

public final class HelmViewController: UIViewController, HelmScreen {
    
    let moduleName: String
    let screenInstanceID: String
    let props: Props
    var screenConfig: [String: Any] = [:]
    
    fileprivate var titleViewTitleLabel: UILabel?
    fileprivate var titleViewSubtitleLabel: UILabel?
    
    public var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            if (statusBarStyle != oldValue) {
                statusBarDirty = true
            }
        }
    }
    public var statusBarHidden: Bool = false {
        didSet {
            if (statusBarHidden != oldValue) {
                statusBarDirty = true
            }
        }
    }
    public var statusBarUpdateAnimation: UIStatusBarAnimation = .fade
    fileprivate var statusBarDirty: Bool = false
    
    private(set) public var isVisible: Bool = false

    var screenConfigRendered: Bool = false {
        didSet {
            if screenConfigRendered {
                screenDidRender()
                onReadyToPresent()
                onReadyToPresent = { }
            }
        }
    }
    var onReadyToPresent: () -> Void = { }
    
    
    // MARK: - Initialization
    
    public init(moduleName: String, props: Props) {
        self.moduleName = moduleName
        
        if let screenInstanceID = props["screenInstanceID"] as? String {
            self.screenInstanceID = screenInstanceID
            self.props = props
        } else {
            self.screenInstanceID = NSUUID().uuidString
            var propsFRD = props
            propsFRD["screenInstanceID"] = screenInstanceID
            self.props = propsFRD
        }
        
        super.init(nibName: nil, bundle: nil)
        
        HelmManager.shared.register(screen: self)
        setupSensibleDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSensibleDefaults() {
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    // MARK: - View lifecycle
    
    override public func loadView() {
        self.view = RCTRootView(bridge: HelmManager.shared.bridge, moduleName: moduleName, initialProperties: props)
    }
    
    // Do stuff that you'd usually do in viewDidLoad here, rather than there.
    // This is due to the way the Screen component works and it's flow with
    // setting the screenConfig and doing a prerender
    private var _screenDidRender = false
    private func screenDidRender() {
        if (_screenDidRender) { return }
        if let title = screenConfig[PropKeys.title] as? String {
            if let subtitle = screenConfig[PropKeys.subtitle] as? String, subtitle.characters.count > 0 {
                let titleStuff = self.titleView(with: title, and: subtitle, given: screenConfig)
                let titleView = titleStuff.titleView
                titleView.isAccessibilityElement = true
                titleView.accessibilityLabel = "\(title), \(subtitle)"
                titleView.accessibilityTraits = UIAccessibilityTraitHeader
                self.navigationItem.titleView = titleView
                self.navigationItem.title = nil
                
                self.titleViewTitleLabel = titleStuff.titleLabel
                self.titleViewSubtitleLabel = titleStuff.subtitleLabel
            }
            self.title = title
        }
        
        if let navBarImagePath = screenConfig[PropKeys.navBarImage] {
            if let titleView: UIView = titleViewFromNavBarImagePath(navBarImagePath: navBarImagePath) {
                titleView.contentMode = .scaleAspectFit
                let container = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                titleView.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                container.addSubview(titleView)
                self.navigationItem.titleView = container
            }
            else {
                self.navigationItem.titleView = nil
            }
        }

        if let backgroundColor = screenConfig[PropKeys.backgroundColor] {
            view.backgroundColor = RCTConvert.uiColor(backgroundColor)
        }
        
        _screenDidRender = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        handleStyles()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
    }
    
    
    // MARK: - Status bar
    
    func updateStatusBarIfNeeded() {
        guard (statusBarDirty) else { return }
        defer { statusBarDirty = false }
        
        let duration = statusBarUpdateAnimation != .none ? 0.2 : 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarUpdateAnimation
    }
    
    override public var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    
    // MARK: - Orientation
    
    public override var shouldAutorotate: Bool {
        return super.shouldAutorotate
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let cantRotate = screenConfig[PropKeys.noRotationInVerticallyCompact] as? Bool, cantRotate, (self.traitCollection.verticalSizeClass == .compact || self.traitCollection.horizontalSizeClass == .compact) {
            return .portrait
        }
        
        return super.supportedInterfaceOrientations
    }
    
    
    // MARK: - Styles
    
    public func handleStyles() {
        // Nav bar props
        let drawUnderNavBar = screenConfig[PropKeys.drawUnderNavBar] as? Bool ?? false
        if (drawUnderNavBar) {
            edgesForExtendedLayout.insert(.top)
        } else {
            edgesForExtendedLayout.remove(.top)
        }
        
        let drawUnderTabBar = screenConfig[PropKeys.drawUnderTabBar] as? Bool ?? false
        if (drawUnderTabBar) {
            edgesForExtendedLayout.insert(.bottom)
        } else {
            edgesForExtendedLayout.remove(.bottom)
        }
        
        if let autoAdjustInsets = screenConfig[PropKeys.automaticallyAdjustsScrollViewInsets] as? Bool {
            automaticallyAdjustsScrollViewInsets = autoAdjustInsets
        }
        
        if screenConfig[PropKeys.navBarTransparent] as? Bool ?? false {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            edgesForExtendedLayout.insert(.top)
            automaticallyAdjustsScrollViewInsets = false
        }
        else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.isTranslucent = screenConfig[PropKeys.navBarTranslucent] as? Bool ?? false
        }
        
        if let navBarStyle = screenConfig[PropKeys.navBarStyle] as? String {
            switch navBarStyle {
            case "dark": navigationController?.navigationBar.barStyle = .black
            case "light": navigationController?.navigationBar.barStyle = .default
            default: navigationController?.navigationBar.barStyle = .default
            }
        }
        
        if screenConfig[PropKeys.hideNavBarShadowImage] as? Bool ?? false {
            navigationController?.navigationBar.shadowImage = UIImage()
        }

        let navBarHidden = screenConfig[PropKeys.navBarHidden] as? Bool ?? false
        if navigationController?.isNavigationBarHidden != navBarHidden {
            navigationController?.setNavigationBarHidden(navBarHidden, animated: true)
        }
        
        if let navBarColor = screenConfig[PropKeys.navBarColor] ?? HelmManager.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarColor] {
            if let navBarColorNone = navBarColor as? String, navBarColorNone == "none" {
                navigationController?.navigationBar.barTintColor = nil
            } else {
                navigationController?.navigationBar.barTintColor = RCTConvert.uiColor(navBarColor)
            }
        }
        
        if let navBarButtonColor = screenConfig[PropKeys.navBarButtonColor] ?? HelmManager.shared.defaultScreenConfiguration[moduleName]?[PropKeys.navBarButtonColor] {
            if let navBarButtonColorNone = navBarButtonColor as? String, navBarButtonColorNone == "none" {
                navigationController?.navigationBar.tintColor = nil
            } else {
                navigationController?.navigationBar.tintColor = RCTConvert.uiColor(navBarButtonColor)
            }
        } else {
            if screenConfig[PropKeys.navBarStyle] as? String == "dark" {
                navigationController?.navigationBar.tintColor = .white
            }
        }
        
        if let c = screenConfig["navBarTitleColor"], let titleColor = RCTConvert.uiColor(c) {
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: titleColor]
        }
        
        func barButtonItems(fromConfig config: [[String: Any]]) -> [UIBarButtonItem] {
            var items: [UIBarButtonItem] = []
            for buttonConfig in config {
                let styleConfig = buttonConfig["style"] as? String
                let style: UIBarButtonItemStyle = styleConfig == "done" ? .done : .plain
                let barButtonItem: UIBarButtonItem
                if let imageConfig = buttonConfig["image"] as? [String: Any],
                    let imageSource = RCTConvert.rctImageSource(imageConfig),
                    let url = imageSource.request.url, url.scheme?.lowercased() == "https" {
                    let button = UIButton(type: .custom)
                    button.kf.setImage(with: url, for: .normal)
                    button.imageView?.contentMode = .scaleAspectFit
                    let view = UIView()
                    if let width = imageConfig["width"] as? CGFloat, let height = imageConfig["height"] as? CGFloat {
                        let frame = CGRect(x: 0, y: 0, width: width, height: height)
                        view.frame = frame
                        button.frame = frame
                    }
                    if let borderRadius = imageConfig["borderRadius"] as? CGFloat {
                        view.layer.cornerRadius = borderRadius
                        view.clipsToBounds = true
                    }
                    if let action = buttonConfig["action"] as? NSString {
                        button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                        button.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                    }
                    view.addSubview(button)
                    barButtonItem = UIBarButtonItem(customView: view)
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig), let simulateBackChevron = buttonConfig["simulateBackChevron"] as? Bool, simulateBackChevron {
                    let button =  UIButton(type: .custom)
                    button.setImage(image, for: .normal)
                    var width: CGFloat = 26
                    let height: CGFloat = 31
                    if let imageConfig = imageConfig as? [String: Any], let w = imageConfig["width"] as? CGFloat, let scale = imageConfig["scale"] as? CGFloat {
                        width = w * scale
                    }
                    button.frame = CGRect(x: 0, y: 0, width: width, height: height)
                    button.imageEdgeInsets = UIEdgeInsetsMake(-1, -width, 1, 0)
                    button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                    if let action = buttonConfig["action"] as? NSString {
                        button.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                    }

                    barButtonItem = UIBarButtonItem(customView: button)
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig), let badgeConfig = buttonConfig["badge"] as? [String: Any] {
                    let frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                    let button =  UIButton(type: .custom)
                    button.frame = frame
                    button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
                    button.addTarget(self, action: #selector(barButtonTapped(_:)), for: .touchUpInside)
                    if let action = buttonConfig["action"] as? NSString {
                        button.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                    }
                    let badged = UIView(frame: frame)
                    badged.isAccessibilityElement = true
                    badged.accessibilityLabel = buttonConfig["accessibilityLabel"] as? String
                    let badgeLabel = UILabel()
                    if let backgroundColor = badgeConfig["backgroundColor"] {
                        badgeLabel.backgroundColor = RCTConvert.uiColor(backgroundColor)
                    }
                    if let textColor = badgeConfig["textColor"] {
                        badgeLabel.textColor = RCTConvert.uiColor(textColor)
                    }
                    if let text = badgeConfig["text"] as? String {
                        badgeLabel.text = text
                    }
                    badgeLabel.font = UIFont.systemFont(ofSize: 10)
                    badgeLabel.sizeToFit()
                    let size = max(badgeLabel.frame.size.width, badgeLabel.frame.size.height)

                    // put the badge in the top right corner
                    badgeLabel.frame = CGRect(x: image.size.width - size, y: -2, width: size, height: size)

                    badgeLabel.layer.masksToBounds = true
                    badgeLabel.layer.cornerRadius = size / 2
                    badgeLabel.textAlignment = .center
                    badged.addSubview(button)
                    badged.addSubview(badgeLabel)
                    barButtonItem = UIBarButtonItem(customView: badged)
                } else if let imageConfig = buttonConfig["image"], let image = RCTConvert.uiImage(imageConfig) {
                    barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(barButtonTapped(_:)))
                } else if let title = buttonConfig["title"] as? String {
                    barButtonItem = UIBarButtonItem(title: title, style: style, target: self, action: #selector(barButtonTapped(_:)))
                } else {
                    continue
                }
                items.append(barButtonItem)
                
                if let action = buttonConfig["action"] as? NSString {
                    barButtonItem.setAssociatedObject(action, forKey: &Associated.barButtonAction)
                }
                
                let disabled = buttonConfig["disabled"] as? Bool ?? false
                barButtonItem.isEnabled = !disabled
                
                if let testID = buttonConfig["testID"] as? String {
                    barButtonItem.accessibilityIdentifier = testID
                }
                if let a11yLabel = buttonConfig["accessibilityLabel"] as? String {
                    barButtonItem.accessibilityLabel = a11yLabel
                }
            }
            return items
        }
        
        let leftBarButtons = screenConfig[PropKeys.leftBarButtons] as? [[String: Any]] ?? []
        navigationItem.leftBarButtonItems = barButtonItems(fromConfig: leftBarButtons)
        
        let rightBarButtons = screenConfig[PropKeys.rightBarButtons] as? [[String: Any]] ?? []
        navigationItem.rightBarButtonItems = barButtonItems(fromConfig: rightBarButtons)
        
        // Status bar props
        if let statusBarStyle = screenConfig[PropKeys.statusBarStyle] as? String {
            switch statusBarStyle {
            case "light":
                self.statusBarStyle = .lightContent
                self.navigationController?.navigationBar.barStyle = .black
            default:
                self.statusBarStyle = .default
                self.navigationController?.navigationBar.barStyle = .default
            }
        }
        // TODO: According to Wix's code, this can't be set on viewWillAppear, and they do it on initialization separately...
        statusBarHidden = screenConfig[PropKeys.statusBarHidden] as? Bool ?? false
        if let animation = screenConfig[PropKeys.statusBarUpdateAnimation] as? String {
            switch animation {
            case "none": self.statusBarUpdateAnimation = .none
            case "fade": self.statusBarUpdateAnimation = .fade
            case "slide": self.statusBarUpdateAnimation = .slide
            default: self.statusBarUpdateAnimation = .fade
            }
        }
        updateStatusBarIfNeeded()
        
        if let backButtonTitle = screenConfig[PropKeys.backButtonTitle] as? String {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: .plain, target: nil, action: nil)
        }
    }
    
    private func titleView(with title: String, and subtitle: String, given config: [String: Any]) -> (titleView: UIView, titleLabel: UILabel, subtitleLabel: UILabel) {
        let titleLabel = UILabel(frame: CGRect(x:0, y:-2, width:0, height:0))
        let subtitleLabel = UILabel(frame: CGRect(x:0, y:18, width:0, height:0))
        styleTitleViewLabels(titleLabel: titleLabel, subtitleLabel: subtitleLabel)
        
        titleLabel.text = title
        titleLabel.sizeToFit()
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()

        let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        if let testID = screenConfig["testID"] as? String {
            titleView.accessibilityIdentifier = testID + ".nav-bar-title-view"
        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
        } else {
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        }
        titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true

        return (titleView, titleLabel, subtitleLabel)
    }
    
    private func styleTitleViewLabels(titleLabel: UILabel, subtitleLabel: UILabel) {
        // TODO: support custom fonts, sizes
        
        let titleColor: UIColor
        if let c = screenConfig["navBarTitleColor"] {
            titleColor = RCTConvert.uiColor(c)
        } else {
            if let style = screenConfig[PropKeys.navBarStyle] as? String {
                if style == "light" {
                    titleColor = .darkText
                } else {
                    titleColor = .white
                }
            } else {
                titleColor = .darkText
            }
        }
        
        let subtitleColor: UIColor
        if let c = screenConfig["navBarSubtitleColor"] {
            subtitleColor = RCTConvert.uiColor(c)
        } else {
            if let style = screenConfig[PropKeys.navBarStyle] as? String {
                if style == "light" {
                    subtitleColor = .darkText
                } else {
                    subtitleColor = .white
                }
            } else {
                subtitleColor = .darkText
            }
        }
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = titleColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textAlignment = .center
        
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
    }
    
    func barButtonTapped(_ barButton: UIBarButtonItem) {
        if let action: NSString = barButton.getAssociatedObject(&Associated.barButtonAction) {
            HelmManager.shared.bridge.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [action])
        }
    }
    
    func titleViewFromNavBarImagePath(navBarImagePath: Any) -> UIView? {
        var titleView: UIView? = nil
        switch (navBarImagePath) {
        case is String:
            if let path = navBarImagePath as? String {
                if (path as NSString).pathExtension == "svg" {
                    let svgImage = SVGKImage(contentsOf: URL(string: path)!)
                    let imageView = UIImageView(image: svgImage?.uiImage)
                    titleView = imageView
                } else {
                    let imageView = UIImageView()
                    imageView.kf.setImage(with: URL(string: path))
                    titleView = imageView
                }
            }
        case is [String: Any]:
            let image = RCTConvert.uiImage(navBarImagePath)
            let imageView = UIImageView(image: image)
            titleView = imageView
            break
        default: break
        }
        return titleView
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let onTraitCollectionChange = screenConfig["onTraitCollectionChange"] as? NSString {
            HelmManager.shared.bridge.enqueueJSCall("RCTDeviceEventEmitter.emit", args: [onTraitCollectionChange])
        }
    }
}

fileprivate struct Associated {
    static var barButtonAction = "barButtonAction"
}
