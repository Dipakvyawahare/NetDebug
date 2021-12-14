#if os(OSX)

  import Cocoa

  protocol WindowControllerDelegate {
    func httpModelSelectedDidChange(model: HTTPModel)
  }

  class WindowController: NSWindowController, NSWindowDelegate, WindowControllerDelegate {

    @IBOutlet var settingsButton: NSButton!
    @IBOutlet var infoButton: NSButton!
    @IBOutlet var statisticsButton: NSButton!

    @IBOutlet var listView: NSView!
    @IBOutlet var detailsView: NSView!
    @IBOutlet var listViewController: ListController_OSX!
    @IBOutlet var detailsViewController: DetailsController_OSX!

    @IBOutlet var settingsPopover: NSPopover!
    @IBOutlet var infoPopover: NSPopover!
    @IBOutlet var statisticsPopover: NSPopover!

    @IBOutlet var settingsViewController: SettingsController_OSX!
    @IBOutlet var settingsView: NSView!

    @IBOutlet var infoViewController: InfoController_OSX!
    @IBOutlet var infoView: NSView!

    @IBOutlet var statisticsViewController: StatisticsController_OSX!
    @IBOutlet var statisticsView: NSView!

    // MARK: Lifecycle

    override func awakeFromNib() {
      settingsButton.image = NSImage(data: Assets.getImage(.settings))
      infoButton.image = NSImage(data: Assets.getImage(.info))
      statisticsButton.image = NSImage(data: Assets.getImage(.statistics))

      listViewController.view = listView
      listViewController.delegate = self
      detailsViewController.view = detailsView

      settingsViewController.view = settingsView
      infoViewController.view = infoView
      statisticsViewController.view = statisticsView

      listViewController.reloadData()
      statisticsViewController.reloadData()
    }

    override func windowDidLoad() {
      super.windowDidLoad()
      window?.delegate = self
    }

    // MARK: NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
      if let window = notification.object as? NSWindow, window == self.window {
        .sharedInstance().windowDidClose()
      }
    }

    // MARK: Actions

    @IBAction func settingsClicked(sender: AnyObject?) {
      settingsPopover.show(
        relativeTo: NSZeroRect, of: settingsButton, preferredEdge: NSRectEdge.maxY)
    }

    @IBAction func infoClicked(sender: AnyObject?) {
      infoPopover.show(relativeTo: NSZeroRect, of: infoButton, preferredEdge: NSRectEdge.maxY)
    }

    @IBAction func statisticsClicked(sender: AnyObject?) {
      statisticsPopover.show(
        relativeTo: NSZeroRect, of: statisticsButton, preferredEdge: NSRectEdge.maxY)
    }

  }

  extension WindowController {
    func httpModelSelectedDidChange(model: HTTPModel) {
      detailsViewController.selectedModel(model)
    }
  }

#endif
