#if os(iOS)
  import UIKit

  typealias Color = UIColor
  typealias Font = UIFont
  typealias Image = UIImage
  typealias ViewController = UIViewController

#elseif os(OSX)
  import Cocoa

  typealias Color = NSColor
  typealias Font = NSFont
  typealias Image = NSImage
  typealias ViewController = NSViewController
#endif
