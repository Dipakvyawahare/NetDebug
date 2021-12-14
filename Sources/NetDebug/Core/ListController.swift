import Foundation

class ListController: GenericController {

  var tableData = [HTTPModel]()
  var filteredTableData = [HTTPModel]()

  func updateSearchResultsForSearchControllerWithString(_ searchString: String) {
    let predicateURL = NSPredicate(format: "requestURL contains[cd] '\(searchString)'")
    let predicateMethod = NSPredicate(format: "requestMethod contains[cd] '\(searchString)'")
    let predicateType = NSPredicate(format: "responseType contains[cd] '\(searchString)'")
    let predicates = [predicateURL, predicateMethod, predicateType]
    let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)

    let array = (HTTPModelManager.shared.getModels() as NSArray).filtered(
      using: searchPredicate)
    filteredTableData = array as! [HTTPModel]
  }

  @objc func reloadTableViewData() {}
}
