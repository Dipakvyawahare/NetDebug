import Foundation

class AuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {

  typealias AuthenticationChallengeHandler = (
    URLSession.AuthChallengeDisposition, URLCredential?
  ) -> Void

  let handler: AuthenticationChallengeHandler

  init(handler: @escaping AuthenticationChallengeHandler) {
    self.handler = handler
    super.init()
  }

  func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
    handler(.useCredential, credential)
  }

  func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
    handler(.useCredential, nil)
  }

  func cancel(_ challenge: URLAuthenticationChallenge) {
    handler(.cancelAuthenticationChallenge, nil)
  }

  func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
    handler(.performDefaultHandling, nil)
  }

  func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
    handler(.rejectProtectionSpace, nil)
  }
}
