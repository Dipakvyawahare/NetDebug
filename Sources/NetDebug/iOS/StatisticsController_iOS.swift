#if os(iOS)

  import UIKit

  class StatisticsController_iOS: StatisticsController {

    var scrollView: UIScrollView = UIScrollView()
    var textLabel: UILabel = UILabel()

    override func viewDidLoad() {
      super.viewDidLoad()

      title = "Statistics"

      generateStatistics()

      scrollView = UIScrollView()
      scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
      scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      scrollView.autoresizesSubviews = true
      scrollView.backgroundColor = UIColor.clear
      view.addSubview(scrollView)

      textLabel = UILabel()
      textLabel.frame = CGRect(
        x: 20, y: 20, width: scrollView.frame.width - 40, height: scrollView.frame.height - 20)
      textLabel.font = UIFont.Font(size: 13)
      textLabel.textColor = UIColor.Gray44Color()
      textLabel.numberOfLines = 0
      textLabel.attributedText = getReportString()
      textLabel.sizeToFit()
      scrollView.addSubview(textLabel)

      scrollView.contentSize = CGSize(width: scrollView.frame.width, height: textLabel.frame.maxY)

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(GenericController.reloadData),
        name: NSNotification.Name.ReloadData,
        object: nil)

    }

    override func reloadData() {
      super.reloadData()
      DispatchQueue.main.async { () -> Void in
        self.textLabel.attributedText = self.getReportString()
      }
    }
  }

#endif
