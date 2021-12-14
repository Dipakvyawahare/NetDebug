#if os(iOS)

  import UIKit
  import MessageUI

  class SettingsController_iOS: SettingsController, UITableViewDelegate,
    UITableViewDataSource, MFMailComposeViewControllerDelegate, DataCleaner
  {

    var tableView: UITableView = UITableView()

    // MARK: View Life Cycle

    override func viewDidLoad() {
      super.viewDidLoad()

      title = "Settings"

      tableData = HTTPModelShortType.allValues
      filters = NetDebug.shared.getCachedFilters()

      edgesForExtendedLayout = UIRectEdge()
      extendedLayoutIncludesOpaqueBars = false
      automaticallyAdjustsScrollViewInsets = false

      navigationItem.rightBarButtonItems = [
        UIBarButtonItem(
          image: UIImage.Statistics(), style: .plain, target: self,
          action: #selector(SettingsController_iOS.statisticsButtonPressed)),
        UIBarButtonItem(
          image: UIImage.Info(), style: .plain, target: self,
          action: #selector(SettingsController_iOS.infoButtonPressed)),
      ]

      tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 60)
      tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      tableView.translatesAutoresizingMaskIntoConstraints = true
      tableView.delegate = self
      tableView.dataSource = self
      tableView.alwaysBounceVertical = false
      tableView.backgroundColor = UIColor.clear
      tableView.tableFooterView = UIView(frame: CGRect.zero)
      tableView.tableFooterView?.isHidden = true
      view.addSubview(tableView)
    }

    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      NetDebug.shared.cacheFilters(self.filters)
    }

    @objc func infoButtonPressed() {
      var infoController: InfoController_iOS
      infoController = InfoController_iOS()
      navigationController?.pushViewController(infoController, animated: true)
    }

    @objc func statisticsButtonPressed() {
      var statisticsController: StatisticsController_iOS
      statisticsController = StatisticsController_iOS()
      navigationController?.pushViewController(statisticsController, animated: true)
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0: return 1
      case 1: return self.tableData.count
      case 2: return 1
      case 3: return 1
      default: return 0
      }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = UITableViewCell()
      cell.textLabel?.font = UIFont.Font(size: 14)
      cell.tintColor = UIColor.OrangeColor()

      switch (indexPath as NSIndexPath).section {
      case 0:
        cell.textLabel?.text = "Logging"
        let EnabledSwitch: UISwitch
        EnabledSwitch = UISwitch()
        EnabledSwitch.setOn(NetDebug.shared.isEnabled(), animated: false)
        EnabledSwitch.addTarget(
          self, action: #selector(SettingsController_iOS.EnabledSwitchValueChanged(_:)),
          for: .valueChanged)
        cell.accessoryView = EnabledSwitch
        return cell

      case 1:
        let shortType = tableData[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = shortType.rawValue
        configureCell(cell, indexPath: indexPath)
        return cell

      case 2:
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = "Share Session Logs"
        cell.textLabel?.textColor = UIColor.GreenColor()
        cell.textLabel?.font = UIFont.Font(size: 16)
        return cell

      case 3:
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = "Clear data"
        cell.textLabel?.textColor = UIColor.RedColor()
        cell.textLabel?.font = UIFont.Font(size: 16)

        return cell

      default: return UITableViewCell()

      }

    }

    func reloadTableData() {
      DispatchQueue.main.async { () -> Void in
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
      }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
      return 4
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let headerView = UIView()
      headerView.backgroundColor = UIColor.Gray95Color()

      switch section {
      case 1:

        var filtersInfoLabel: UILabel
        filtersInfoLabel = UILabel(frame: headerView.bounds)
        filtersInfoLabel.backgroundColor = UIColor.clear
        filtersInfoLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        filtersInfoLabel.font = UIFont.Font(size: 13)
        filtersInfoLabel.textColor = UIColor.Gray44Color()
        filtersInfoLabel.textAlignment = .center
        filtersInfoLabel.text = "\nSelect the types of responses that you want to see"
        filtersInfoLabel.numberOfLines = 2
        headerView.addSubview(filtersInfoLabel)

      default: break
      }

      return headerView

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      switch (indexPath as NSIndexPath).section {
      case 1:
        let cell = tableView.cellForRow(at: indexPath)
        self.filters[(indexPath as NSIndexPath).row] = !self.filters[(indexPath as NSIndexPath).row]
        configureCell(cell, indexPath: indexPath)
        break

      case 2:
        shareSessionLogsPressed()
        break

      case 3:
        clearDataButtonPressedOnTableIndex(indexPath)
        break

      default: break
      }

      tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      switch (indexPath as NSIndexPath).section {
      case 0: return 44
      case 1: return 33
      case 2, 3: return 44
      default: return 0
      }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      let iPhone4s = (UIScreen.main.bounds.height == 480)
      switch section {
      case 0:
        if iPhone4s {
          return 20
        } else {
          return 40
        }
      case 1:
        if iPhone4s {
          return 50
        } else {
          return 60
        }
      case 2, 3:
        if iPhone4s {
          return 25
        } else {
          return 50
        }

      default: return 0
      }
    }

    func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
      if cell != nil {
        if filters[(indexPath as NSIndexPath).row] {
          cell!.accessoryType = .checkmark
        } else {
          cell!.accessoryType = .none
        }
      }
    }

    @objc func EnabledSwitchValueChanged(_ sender: UISwitch) {
      if sender.isOn {
        NetDebug.shared.enable()
      } else {
        NetDebug.shared.disable()
      }
    }

    func clearDataButtonPressedOnTableIndex(_ index: IndexPath) {

      clearData(sourceView: tableView, originingIn: tableView.rectForRow(at: index)) {}
    }

    func shareSessionLogsPressed() {
      if MFMailComposeViewController.canSendMail() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self

        mailComposer.setSubject("netfox log - Session Log \(NSDate())")
        if let sessionLogData = NSData(contentsOfFile: Path.SessionLog as String) {
          mailComposer.addAttachmentData(
            sessionLogData as Data, mimeType: "text/plain", fileName: "session.log")
        }

        present(mailComposer, animated: true, completion: nil)
      }
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      dismiss(animated: true, completion: nil)
    }
  }

#endif
