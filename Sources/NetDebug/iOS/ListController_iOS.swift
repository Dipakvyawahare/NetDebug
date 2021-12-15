#if os(iOS)

  import Foundation
  import UIKit

  class ListController_iOS: ListController, UITableViewDelegate, UITableViewDataSource,
    UISearchResultsUpdating, UISearchControllerDelegate, DataCleaner
  {
    // MARK: Properties

    var tableView: UITableView = UITableView()
    var searchController: UISearchController!

    // MARK: View Life Cycle

    override func viewDidLoad() {
      super.viewDidLoad()

      edgesForExtendedLayout = UIRectEdge.all
      extendedLayoutIncludesOpaqueBars = true
      automaticallyAdjustsScrollViewInsets = false
      tableView.frame = self.view.frame
      tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      tableView.translatesAutoresizingMaskIntoConstraints = true
      tableView.delegate = self
      tableView.dataSource = self
      view.addSubview(self.tableView)
      tableView.register(
        ListCell.self, forCellReuseIdentifier: NSStringFromClass(ListCell.self))

      navigationItem.rightBarButtonItem = UIBarButtonItem(
        image: UIImage.Close(), style: .plain, target: self,
        action: #selector(ListController_iOS.closeButtonPressed))

      let leftButtons = [
        UIBarButtonItem(
          barButtonSystemItem: .trash, target: self,
          action: #selector(ListController_iOS.trashButtonPressed)),
        UIBarButtonItem(
          image: UIImage.Settings(), style: .plain, target: self,
          action: #selector(ListController_iOS.settingsButtonPressed)),
      ]

      self.navigationItem.leftBarButtonItems = leftButtons

      searchController = UISearchController(searchResultsController: nil)
      searchController.searchResultsUpdater = self
      searchController.delegate = self
      searchController.hidesNavigationBarDuringPresentation = false
      searchController.dimsBackgroundDuringPresentation = false
      searchController.searchBar.autoresizingMask = [.flexibleWidth]
      searchController.searchBar.backgroundColor = UIColor.clear
      searchController.searchBar.barTintColor = UIColor.OrangeColor()
      searchController.searchBar.tintColor = UIColor.OrangeColor()
      searchController.searchBar.searchBarStyle = .minimal
      searchController.view.backgroundColor = UIColor.clear

      if #available(iOS 11.0, *) {
        navigationItem.searchController = searchController
        definesPresentationContext = true
      } else {
        let searchView = UIView()
        searchView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: 0)
        searchView.autoresizingMask = [.flexibleWidth]
        searchView.autoresizesSubviews = true
        searchView.backgroundColor = UIColor.clear
        searchView.addSubview(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        searchView.frame = searchController.searchBar.frame

        navigationItem.titleView = searchView
      }

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(ListController.reloadTableViewData),
        name: NSNotification.Name.ReloadData,
        object: nil)

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(ListController_iOS.deactivateSearchController),
        name: NSNotification.Name.DeactivateSearch,
        object: nil)
      navigationController?.navigationBar.backgroundColor = .white
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      reloadTableViewData()
    }

    override func reloadTableViewData() {
      DispatchQueue.main.async {
        self.tableView.reloadData()
        self.tableView.setNeedsDisplay()
      }
    }

    @objc func settingsButtonPressed() {
      var settingsController: SettingsController_iOS
      settingsController = SettingsController_iOS()
      navigationController?.pushViewController(settingsController, animated: true)
    }

    @objc func trashButtonPressed() {
      clearData(sourceView: tableView, originingIn: nil) {
        self.reloadTableViewData()
      }
    }

    @objc func closeButtonPressed() {
      NetDebug.shared.hide()
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for searchController: UISearchController) {
      updateSearchResultsForSearchControllerWithString(searchController.searchBar.text!)
      reloadTableViewData()
    }

    @objc func deactivateSearchController() {
      searchController.isActive = false
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if searchController.isActive {
        return filteredTableData.count
      } else {
        return HTTPModelManager.shared.getModels().count
      }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell =
        tableView.dequeueReusableCell(
          withIdentifier: NSStringFromClass(ListCell.self), for: indexPath) as! ListCell

      if searchController.isActive {
        if !filteredTableData.isEmpty {
          let obj = filteredTableData[(indexPath as NSIndexPath).row]
          cell.configForObject(obj)
        }
      } else {
        if HTTPModelManager.shared.getModels().count > 0 {
          let obj = HTTPModelManager.shared.getModels()[(indexPath as NSIndexPath).row]
          cell.configForObject(obj)
        }
      }

      return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
      return UIView.init(frame: CGRect.zero)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      var detailsController: DetailsController_iOS
      detailsController = DetailsController_iOS()
      var model: HTTPModel
      if searchController.isActive {
        model = filteredTableData[(indexPath as NSIndexPath).row]
      } else {
        model = HTTPModelManager.shared.getModels()[(indexPath as NSIndexPath).row]
      }
      detailsController.selectedModel(model)
      navigationController?.pushViewController(detailsController, animated: true)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 58
    }

  }

#endif
