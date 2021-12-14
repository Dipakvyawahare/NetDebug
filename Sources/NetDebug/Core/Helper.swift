import Foundation

#if os(OSX)
  import Cocoa
#else
  import UIKit
#endif

public enum HTTPModelShortType: String {
  case JSON = "JSON"
  case XML = "XML"
  case HTML = "HTML"
  case IMAGE = "Image"
  case OTHER = "Other"

  static let allValues = [JSON, XML, HTML, IMAGE, OTHER]
}

extension Color {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")

    self.init(
      red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0,
      alpha: 1.0)
  }

  convenience init(netHex: Int) {
    self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
  }

  class func OrangeColor() -> Color {
    return Color.init(netHex: 0xec5e28)
  }

  class func GreenColor() -> Color {
    return Color.init(netHex: 0x38bb93)
  }

  class func DarkGreenColor() -> Color {
    return Color.init(netHex: 0x2d7c6e)
  }

  class func RedColor() -> Color {
    return Color.init(netHex: 0xd34a33)
  }

  class func DarkRedColor() -> Color {
    return Color.init(netHex: 0x643026)
  }

  class func StarkWhiteColor() -> Color {
    return Color.init(netHex: 0xccc5b9)
  }

  class func DarkStarkWhiteColor() -> Color {
    return Color.init(netHex: 0x9b958d)
  }

  class func LightGrayColor() -> Color {
    return Color.init(netHex: 0x9b9b9b)
  }

  class func Gray44Color() -> Color {
    return Color.init(netHex: 0x707070)
  }

  class func Gray95Color() -> Color {
    return Color.init(netHex: 0xf2f2f2)
  }

  class func BlackColor() -> Color {
    return Color.init(netHex: 0x231f20)
  }
}

extension Font {
  #if os(iOS)
    class func Font(size: CGFloat) -> UIFont {
      return UIFont(name: "HelveticaNeue", size: size)!
    }

    class func FontBold(size: CGFloat) -> UIFont {
      return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }

  #elseif os(OSX)
    class func Font(size: CGFloat) -> NSFont {
      return NSFont(name: "HelveticaNeue", size: size)!
    }

    class func FontBold(size: CGFloat) -> NSFont {
      return NSFont(name: "HelveticaNeue-Bold", size: size)!
    }
  #endif
}

extension URLRequest {
  func getURL() -> String {
    if url != nil {
      return url!.absoluteString
    } else {
      return "-"
    }
  }

  func getURLComponents() -> URLComponents? {
    guard let url = self.url else {
      return nil
    }
    return URLComponents(string: url.absoluteString)
  }

  func getMethod() -> String {
    if httpMethod != nil {
      return httpMethod!
    } else {
      return "-"
    }
  }

  func getCachePolicy() -> String {
    switch cachePolicy {
    case .useProtocolCachePolicy: return "UseProtocolCachePolicy"
    case .reloadIgnoringLocalCacheData: return "ReloadIgnoringLocalCacheData"
    case .reloadIgnoringLocalAndRemoteCacheData: return "ReloadIgnoringLocalAndRemoteCacheData"
    case .returnCacheDataElseLoad: return "ReturnCacheDataElseLoad"
    case .returnCacheDataDontLoad: return "ReturnCacheDataDontLoad"
    case .reloadRevalidatingCacheData: return "ReloadRevalidatingCacheData"
    @unknown default: return "Unknown \(cachePolicy)"
    }
  }

  func getTimeout() -> String {
    return String(Double(timeoutInterval))
  }

  func getHeaders() -> [AnyHashable: Any] {
    if let httpHeaders = allHTTPHeaderFields {
      return httpHeaders
    } else {
      return Dictionary()
    }
  }

  func getBody() -> Data {
    return httpBodyStream?.readfully() ?? URLProtocol.property(forKey: "BodyData", in: self)
      as? Data ?? Data()
  }

  func getCurl() -> String {
    guard let url = url else { return "" }
    let baseCommand = "curl \(url.absoluteString)"

    var command = [baseCommand]

    if let method = httpMethod {
      command.append("-X \(method)")
    }

    for (key, value) in getHeaders() {
      command.append("-H \u{22}\(key): \(value)\u{22}")
    }

    if let body = String(data: getBody(), encoding: .utf8) {
      command.append("-d \u{22}\(body)\u{22}")
    }

    return command.joined(separator: " ")
  }
}

extension URLResponse {
  func getStatus() -> Int {
    return (self as? HTTPURLResponse)?.statusCode ?? 999
  }

  func getHeaders() -> [AnyHashable: Any] {
    return (self as? HTTPURLResponse)?.allHeaderFields ?? [:]
  }
}

extension Image {
  class func Settings() -> Image {
    #if os(iOS)
      return UIImage(data: Assets.getImage(AssetName.settings), scale: 1.7)!
    #elseif os(OSX)
      return NSImage(data: Assets.getImage(AssetName.settings))!
    #endif
  }

  class func Close() -> Image {
    #if os(iOS)
      return UIImage(data: Assets.getImage(AssetName.close), scale: 1.7)!
    #elseif os(OSX)
      return NSImage(data: Assets.getImage(AssetName.close))!
    #endif
  }

  class func Info() -> Image {
    #if os(iOS)
      return UIImage(data: Assets.getImage(AssetName.info), scale: 1.7)!
    #elseif os(OSX)
      return NSImage(data: Assets.getImage(AssetName.info))!
    #endif
  }

  class func Statistics() -> Image {
    #if os(iOS)
      return UIImage(data: Assets.getImage(AssetName.statistics), scale: 1.7)!
    #elseif os(OSX)
      return NSImage(data: Assets.getImage(AssetName.statistics))!
    #endif
  }
}

extension InputStream {
  func readfully() -> Data {
    var result = Data()
    var buffer = [UInt8](repeating: 0, count: 4096)

    open()

    var amount = 0
    repeat {
      amount = read(&buffer, maxLength: buffer.count)
      if amount > 0 {
        result.append(buffer, count: amount)
      }
    } while amount > 0

    close()

    return result
  }
}

extension Date {
  func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
    return compare(dateToCompare) == ComparisonResult.orderedDescending
  }
}

class DebugInfo {

  class func getAppName() -> String {
    return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
  }

  class func getAppVersionNumber() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  }

  class func getAppBuildNumber() -> String {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
  }

  class func getBundleIdentifier() -> String {
    return Bundle.main.bundleIdentifier ?? ""
  }

  class func getOSVersion() -> String {
    #if os(iOS)
      return UIDevice.current.systemVersion
    #elseif os(OSX)
      return ProcessInfo.processInfo.operatingSystemVersionString
    #endif
  }

  class func getDeviceType() -> String {
    #if os(iOS)
      return UIDevice.getDeviceType()
    #elseif os(OSX)
      return "Not implemented yet. PR welcomes"
    #endif
  }

  class func getDeviceScreenResolution() -> String {
    #if os(iOS)
      let scale = UIScreen.main.scale
      let bounds = UIScreen.main.bounds
      let width = bounds.size.width * scale
      let height = bounds.size.height * scale
      return "\(width) x \(height)"
    #elseif os(OSX)
      return "0"
    #endif
  }

  class func getIP(_ completion: @escaping (_ result: String) -> Void) {
    var req: NSMutableURLRequest
    req = NSMutableURLRequest(url: URL(string: "https://api.ipify.org/?format=json")!)
    URLProtocol.setProperty(true, forKey: Protocol.InternalKey, in: req)

    let session = URLSession.shared
    session.dataTask(
      with: req as URLRequest,
      completionHandler: { (data, response, error) in
        do {
          let rawJsonData = try JSONSerialization.jsonObject(
            with: data!, options: [.allowFragments])
          if let ipAddress = (rawJsonData as AnyObject).value(forKey: "ip") {
            completion(ipAddress as! String)
          } else {
            completion("-")
          }
        } catch {
          completion("-")
        }

      }
    ).resume()
  }

}

struct Path {
  static let Documents =
    NSSearchPathForDirectoriesInDomains(
      FileManager.SearchPathDirectory.documentDirectory,
      FileManager.SearchPathDomainMask.allDomainsMask, true
    ).first! as NSString

  static let SessionLog = Path.Documents.appendingPathComponent("session.log")
}

extension String {
  func appendToFile(filePath: String) {
    let contentToAppend = self

    if let fileHandle = FileHandle(forWritingAtPath: filePath) {
      /* Append to file */
      fileHandle.seekToEndOfFile()
      fileHandle.write(contentToAppend.data(using: String.Encoding.utf8)!)
    } else {
      /* Create new file */
      do {
        try contentToAppend.write(
          toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
      } catch {
        print("Error creating \(filePath)")
      }
    }
  }
}

@objc extension URLSessionConfiguration {
  private static var firstOccurrence = true

  static func implementNetfox() {
    guard firstOccurrence else { return }
    firstOccurrence = false

    // First let's make sure setter: URLSessionConfiguration.protocolClasses is de-duped
    // This ensures Protocol won't be added twice
    swizzleProtocolSetter()

    // Now, let's make sure Protocol is always included in the default and ephemeral configuration(s)
    // Adding it twice won't be an issue anymore, because we've de-duped the setter
    swizzleDefault()
    swizzleEphemeral()
  }

  private static func swizzleProtocolSetter() {
    let instance = URLSessionConfiguration.default

    let aClass: AnyClass = object_getClass(instance)!

    let origSelector = #selector(setter:URLSessionConfiguration.protocolClasses)
    let newSelector = #selector(setter:URLSessionConfiguration.protocolClasses_Swizzled)

    let origMethod = class_getInstanceMethod(aClass, origSelector)!
    let newMethod = class_getInstanceMethod(aClass, newSelector)!

    method_exchangeImplementations(origMethod, newMethod)
  }

  @objc private var protocolClasses_Swizzled: [AnyClass]? {
    get {
      // Unused, but required for compiler
      return self.protocolClasses_Swizzled
    }
    set {
      guard let newTypes = newValue else {
        self.protocolClasses_Swizzled = nil
        return
      }

      var types = [AnyClass]()

      // de-dup
      for newType in newTypes {
        if !types.contains(where: { $0 == newType }) {
          types.append(newType)
        }
      }

      self.protocolClasses_Swizzled = types
    }
  }

  private static func swizzleDefault() {
    let aClass: AnyClass = object_getClass(self)!

    let origSelector = #selector(getter:URLSessionConfiguration.default)
    let newSelector = #selector(getter:URLSessionConfiguration.default_swizzled)

    let origMethod = class_getClassMethod(aClass, origSelector)!
    let newMethod = class_getClassMethod(aClass, newSelector)!

    method_exchangeImplementations(origMethod, newMethod)
  }

  private static func swizzleEphemeral() {
    let aClass: AnyClass = object_getClass(self)!

    let origSelector = #selector(getter:URLSessionConfiguration.ephemeral)
    let newSelector = #selector(getter:URLSessionConfiguration.ephemeral_swizzled)

    let origMethod = class_getClassMethod(aClass, origSelector)!
    let newMethod = class_getClassMethod(aClass, newSelector)!

    method_exchangeImplementations(origMethod, newMethod)
  }

  @objc private class var default_swizzled: URLSessionConfiguration {
    let config = URLSessionConfiguration.default_swizzled

    // Let's go ahead and add in Protocol, since it's safe to do so.
    config.protocolClasses?.insert(Protocol.self, at: 0)

    return config
  }

  @objc private class var ephemeral_swizzled: URLSessionConfiguration {
    let config = URLSessionConfiguration.ephemeral_swizzled

    // Let's go ahead and add in Protocol, since it's safe to do so.
    config.protocolClasses?.insert(Protocol.self, at: 0)

    return config
  }
}

extension NSNotification.Name {
  public static let DeactivateSearch = Notification.Name("DeactivateSearch")
  public static let ReloadData = Notification.Name("ReloadData")
  public static let AddedModel = Notification.Name("AddedModel")
  public static let ClearedModels = Notification.Name("ClearedModels")
}
