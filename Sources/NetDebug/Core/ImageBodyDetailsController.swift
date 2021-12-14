#if os(iOS)

  import Foundation
  import UIKit

  class ImageBodyDetailsController: GenericBodyDetailsController {
    var imageView: UIImageView = UIImageView()

    override func viewDidLoad() {
      super.viewDidLoad()

      let viewFrame = view.frame

      title = "Image preview"

      imageView.frame = CGRect(
        x: 10,
        y: 10,
        width: viewFrame.width - 2 * 10,
        height: viewFrame.height - 2 * 10)
      imageView.autoresizingMask = [
        .flexibleWidth,
        .flexibleHeight,
      ]
      imageView.contentMode = .scaleAspectFit
      let data = Data.init(
        base64Encoded: selectedModel.getResponseBody() as String,
        options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)

      imageView.image = UIImage(data: data!)
      view.addSubview(imageView)
    }
  }

#endif
