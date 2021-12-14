import Foundation

enum BodyType: Int {
  case request = 0
  case response = 1
}

class GenericBodyDetailsController: GenericController {
  var bodyType: BodyType = BodyType.response
}
