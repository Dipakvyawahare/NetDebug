import Foundation

#if os(iOS)
  import UIKit
#elseif os(OSX)
  import Cocoa
#endif

class GenericController: ViewController {
  var selectedModel: HTTPModel = HTTPModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    #if os(iOS)
      edgesForExtendedLayout = UIRectEdge.all
      view.backgroundColor = Color.Gray95Color()
    #elseif os(OSX)
      view.wantsLayer = true
      view.layer?.backgroundColor = Color.Gray95Color().cgColor
    #endif
  }

  func selectedModel(_ model: HTTPModel) {
    selectedModel = model
  }

  func formatString(_ string: String) -> NSAttributedString {
    var tempMutableString = NSMutableAttributedString()
    tempMutableString = NSMutableAttributedString(string: string)

    let stringCount = string.count

    let regexBodyHeaders = try! NSRegularExpression(
      pattern: "(\\-- Body \\--)|(\\-- Headers \\--)",
      options: NSRegularExpression.Options.caseInsensitive)
    let matchesBodyHeaders =
      regexBodyHeaders.matches(
        in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
        range: NSMakeRange(0, stringCount)) as [NSTextCheckingResult]

    for match in matchesBodyHeaders {
      tempMutableString.addAttribute(
        .font, value: Font.FontBold(size: 14), range: match.range)
      tempMutableString.addAttribute(
        .foregroundColor, value: Color.OrangeColor(), range: match.range)
    }

    let regexKeys = try! NSRegularExpression(
      pattern: "\\[.+?\\]", options: NSRegularExpression.Options.caseInsensitive)
    let matchesKeys =
      regexKeys.matches(
        in: string, options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
        range: NSMakeRange(0, stringCount)) as [NSTextCheckingResult]

    for match in matchesKeys {
      tempMutableString.addAttribute(
        .foregroundColor, value: Color.BlackColor(), range: match.range)
      tempMutableString.addAttribute(
        .link,
        value: (string as NSString).substring(with: match.range),
        range: match.range)
    }

    return tempMutableString
  }

  @objc func reloadData() {}
}
