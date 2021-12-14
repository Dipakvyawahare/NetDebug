import Foundation

private let _sharedInstance = HTTPModelManager()

final class HTTPModelManager: NSObject {
  static let shared = HTTPModelManager()
  fileprivate var models = [HTTPModel]()
  private let syncQueue = DispatchQueue(label: "SyncQueue")

  func add(_ obj: HTTPModel) {
    syncQueue.async {
      self.models.insert(obj, at: 0)
      NotificationCenter.default.post(name: NSNotification.Name.AddedModel, object: obj)
    }
  }

  func clear() {
    syncQueue.async {
      self.models.removeAll()
      NotificationCenter.default.post(name: NSNotification.Name.ClearedModels, object: nil)
    }
  }

  func getModels() -> [HTTPModel] {
    var predicates = [NSPredicate]()

    let filterValues = NetDebug.shared.getCachedFilters()
    let filterNames = HTTPModelShortType.allValues

    for (index, filterValue) in filterValues.enumerated() {
      if filterValue {
        let filterName = filterNames[index].rawValue
        let predicate = NSPredicate(format: "shortType == '\(filterName)'")
        predicates.append(predicate)
      }
    }

    let searchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
    let array = (models as NSArray).filtered(using: searchPredicate)
    return array as! [HTTPModel]
  }
}
