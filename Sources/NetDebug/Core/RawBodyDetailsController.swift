#if os(iOS)

  import Foundation
  import UIKit

  class RawBodyDetailsController: GenericBodyDetailsController {
    var bodyView: UITextView = UITextView()
    private var copyAlert: UIAlertController?

    override func viewDidLoad() {
      super.viewDidLoad()
      let viewFrame = view.frame

      title = "Body details"

      bodyView.frame = CGRect(x: 0, y: 0, width: viewFrame.width, height: viewFrame.height)
      bodyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      bodyView.backgroundColor = UIColor.clear
      bodyView.textColor = UIColor.Gray44Color()
      bodyView.textAlignment = .left
      bodyView.isEditable = false
      bodyView.isSelectable = false
      bodyView.font = UIFont.Font(size: 13)

      let lpgr = UILongPressGestureRecognizer(
        target: self, action: #selector(RawBodyDetailsController.copyLabel))
      bodyView.addGestureRecognizer(lpgr)

      switch bodyType {
      case .request:
        bodyView.text = selectedModel.getRequestBody() as String
      default:
        bodyView.text = selectedModel.getResponseBody() as String
      }

      view.addSubview(bodyView)
    }

    @objc fileprivate func copyLabel(lpgr: UILongPressGestureRecognizer) {
      guard let text = (lpgr.view as? UITextView)?.text,
        copyAlert == nil
      else { return }

      UIPasteboard.general.string = text

      let alert = UIAlertController(title: "Text Copied!", message: nil, preferredStyle: .alert)
      copyAlert = alert

      present(alert, animated: true) { [weak self] in
        guard let `self` = self else { return }

        Timer.scheduledTimer(
          timeInterval: 0.45,
          target: self,
          selector: #selector(RawBodyDetailsController.dismissCopyAlert),
          userInfo: nil,
          repeats: false)
      }
    }

    @objc fileprivate func dismissCopyAlert() {
      copyAlert?.dismiss(animated: true) { [weak self] in self?.copyAlert = nil }
    }
  }

#endif
