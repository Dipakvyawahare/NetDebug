import Foundation

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

private func podPlistVersion() -> String? {
  guard
    let path =
      Bundle(identifier: "com.kasketis.netfox-iOS")?.infoDictionary?["CFBundleShortVersionString"]
      as? String
  else { return nil }
  return path
}

// TODO: Carthage support
let Version = podPlistVersion() ?? "0"

// Notifications posted when  opens/closes, for client application that wish to log that information.
let WillOpenNotification = "WillOpenNotification"
let WillCloseNotification = "WillCloseNotification"

@objc
open class NetDebug: NSObject {

  // MARK: - Properties

  #if os(OSX)
    var windowController: WindowController?
    let mainMenu: NSMenu? = NSApp.mainMenu?.items[1].submenu
    var MenuItem: NSMenuItem = NSMenuItem(
      title: "netfox", action: #selector(NetDebug.show),
      keyEquivalent: String.init(describing: (character: NSF9FunctionKey, length: 1)))
  #endif

  fileprivate enum Constants: String {
    case alreadyStartedMessage = "Already started!"
    case alreadyStoppedMessage = "Already stopped!"
    case startedMessage = "Started!"
    case stoppedMessage = "Stopped!"
    case prefixForCheck = ""
    case nibName = "NetfoxWindow"
  }

  fileprivate var started: Bool = false
  fileprivate var presented: Bool = false
  fileprivate var enabled: Bool = false
  fileprivate var selectedGesture: EGesture = .shake
  fileprivate var ignoredURLs = [String]()
  fileprivate var ignoredURLsRegex = [NSRegularExpression]()
  fileprivate var filters = [Bool]()
  fileprivate var lastVisitDate: Date = Date()

  internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed

  public static let shared = NetDebug()

  @objc public enum EGesture: Int {
    case shake
    case custom
  }

  @objc open func start() {
    guard !started else {
      showMessage(Constants.alreadyStartedMessage.rawValue)
      return
    }

    started = true
    URLSessionConfiguration.implementNetfox()
    register()
    enable()
    clearOldData()
    showMessage(Constants.startedMessage.rawValue)
    #if os(OSX)
      addNetfoxToMainMenu()
    #endif
  }

  @objc open func stop() {
    guard started else {
      showMessage(Constants.alreadyStoppedMessage.rawValue)
      return
    }

    unregister()
    disable()
    clearOldData()
    started = false
    showMessage(Constants.stoppedMessage.rawValue)
    #if os(OSX)
      removeNetfoxFromMainmenu()
    #endif
  }

  fileprivate func showMessage(_ msg: String) {
    //
  }

  internal func isEnabled() -> Bool {
    return enabled
  }

  internal func enable() {
    enabled = true
  }

  internal func disable() {
    enabled = false
  }

  fileprivate func register() {
    URLProtocol.registerClass(Protocol.self)
  }

  fileprivate func unregister() {
    URLProtocol.unregisterClass(Protocol.self)
  }

  @objc public func motionDetected() {
    guard started else { return }
    toggleScreen()
  }

  @objc open func isStarted() -> Bool {
    return started
  }

  @objc open func setCachePolicy(_ policy: URLCache.StoragePolicy) {
    cacheStoragePolicy = policy
  }

  @objc open func setGesture(_ gesture: EGesture) {
    selectedGesture = gesture
    #if os(OSX)
      if gesture == .shake {
        addNetfoxToMainMenu()
      } else {
        removeNetfoxFromMainmenu()
      }
    #endif
  }

  @objc open func show() {
    guard started else { return }
    showScreen()
  }

  @objc open func hide() {
    guard started else { return }
    hideScreen()
  }

  @objc open func toggle() {
    guard self.started else { return }
    toggleScreen()
  }

  @objc open func ignoreURL(_ url: String) {
    ignoredURLs.append(url)
  }

  @objc open func getSessionLog() -> Data? {
    var data: Data? = nil
    if let sessionLogData = try? Data(contentsOf: URL(fileURLWithPath: Path.SessionLog)) {
      data = sessionLogData
    }

    return data
  }

  @objc open func ignoreURLs(_ urls: [String]) {
    ignoredURLs.append(contentsOf: urls)
  }

  @objc open func ignoreURLsWithRegex(_ regex: String) {
    ignoredURLsRegex.append(NSRegularExpression(regex))
  }

  @objc open func ignoreURLsWithRegexes(_ regexes: [String]) {
    ignoredURLsRegex.append(contentsOf: regexes.map { NSRegularExpression($0) })
  }

  internal func getLastVisitDate() -> Date {
    return lastVisitDate
  }

  fileprivate func showScreen() {
    if presented {
      return
    }

    showFollowingPlatform()
    presented = true

  }

  fileprivate func hideScreen() {
    if !presented {
      return
    }

    NotificationCenter.default.post(name: Notification.Name.DeactivateSearch, object: nil)
    hideFollowingPlatform { () -> Void in
      self.presented = false
      self.lastVisitDate = Date()
    }
  }

  fileprivate func toggleScreen() {
    presented ? hide() : show()
  }

  internal func clearOldData() {
    HTTPModelManager.shared.clear()
    do {
      let documentsPath = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.allDomainsMask, true
      ).first!
      let filePathsArray = try FileManager.default.subpathsOfDirectory(atPath: documentsPath)
      for filePath in filePathsArray {
        if filePath.hasPrefix(Constants.prefixForCheck.rawValue) {
          try FileManager.default.removeItem(
            atPath: (documentsPath as NSString).appendingPathComponent(filePath))
        }
      }

      try FileManager.default.removeItem(atPath: Path.SessionLog)
    } catch {}
  }

  func getIgnoredURLs() -> [String] {
    return ignoredURLs
  }

  func getIgnoredURLsRegexes() -> [NSRegularExpression] {
    return ignoredURLsRegex
  }

  func getSelectedGesture() -> EGesture {
    return selectedGesture
  }

  func cacheFilters(_ selectedFilters: [Bool]) {
    filters = selectedFilters
  }

  func getCachedFilters() -> [Bool] {
    if filters.isEmpty {
      filters = [Bool](repeating: true, count: HTTPModelShortType.allValues.count)
    }
    return filters
  }

}

#if os(iOS)

  extension NetDebug {
    fileprivate var presentingViewController: UIViewController? {
      var rootViewController = UIApplication.shared.keyWindow?.rootViewController
      while let controller = rootViewController?.presentedViewController {
        rootViewController = controller
      }
      return rootViewController
    }

    fileprivate func showFollowingPlatform() {
      let navigationController = UINavigationController(rootViewController: ListController_iOS())
      navigationController.navigationBar.isTranslucent = false
      navigationController.navigationBar.tintColor = UIColor.OrangeColor()
      navigationController.navigationBar.barTintColor = UIColor.StarkWhiteColor()
      navigationController.navigationBar.titleTextAttributes = [
        .foregroundColor: UIColor.OrangeColor()
      ]

      if #available(iOS 13.0, *) {
        navigationController.presentationController?.delegate = self
      }

      presentingViewController?.present(navigationController, animated: true, completion: nil)
    }

    fileprivate func hideFollowingPlatform(_ completion: (() -> Void)?) {
      presentingViewController?.dismiss(
        animated: true,
        completion: { () -> Void in
          if let notNilCompletion = completion {
            notNilCompletion()
          }
        })
    }
  }

  extension NetDebug: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
      guard self.started else { return }
      self.presented = false
    }
  }

#elseif os(OSX)

  extension NetDebug {

    public func windowDidClose() {
      presented = false
    }

    private func setupNetfoxMenuItem() {
      MenuItem.target = self
      MenuItem.action = #selector(NetDebug.motionDetected)
      MenuItem.keyEquivalent = "n"
      MenuItem.keyEquivalentModifierMask = NSEvent.ModifierFlags(
        rawValue: UInt(
          Int(NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)))
    }

    public func addNetfoxToMainMenu() {
      setupNetfoxMenuItem()
      if let menu = mainMenu {
        menu.insertItem(MenuItem, at: 0)
      }
    }

    public func removeNetfoxFromMainmenu() {
      if let menu = mainMenu {
        menu.removeItem(MenuItem)
      }
    }

    public func showFollowingPlatform() {
      if windowController == nil {
        #if swift(>=4.2)
          let nibName = Constants.nibName.rawValue
        #else
          let nibName = NSNib.Name(rawValue: Constants.nibName.rawValue)
        #endif

        windowController = WindowController(windowNibName: nibName)
      }
      windowController?.showWindow(nil)
    }

    public func hideFollowingPlatform(completion: (() -> Void)?) {
      windowController?.close()
      if let notNilCompletion = completion {
        notNilCompletion()
      }
    }
  }

#endif
