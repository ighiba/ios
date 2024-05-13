import UIKit
import TKUIKit

final class SignQRCodeViewController: GenericViewViewController<SignQRCodeView>, TKBottomSheetContentViewController {
  private let viewModel: SignQRCodeViewModel
  
  private var cachedWidth: CGFloat?
  
  // MARK: - Init
  
  init(viewModel: SignQRCodeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    setupBindings()
    viewModel.viewDidLoad()
  }
  
  // MARK: - TKBottomSheetContentViewController

  
  var didUpdateHeight: (() -> Void)?
  
  var headerItem: TKUIKit.TKPullCardHeaderItem?
  
  var didUpdatePullCardHeaderItem: ((TKUIKit.TKPullCardHeaderItem) -> Void)?
  
  func calculateHeight(withWidth width: CGFloat) -> CGFloat {
    customView.containerView.systemLayoutSizeFitting(
      CGSize(
        width: width,
        height: 0
      ),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    ).height
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    customView.qrCodeView.layoutIfNeeded()
    if cachedWidth != customView.bounds.width {
      cachedWidth = customView.bounds.width
      viewModel.generateQRCode(width: customView.qrCodeView.qrCodeImageViewContainer.bounds.width)
    }
  }
}

// MARK: - Private

private extension SignQRCodeViewController {
  func setup() {}

  func setupBindings() {
    viewModel.didUpdateModel = { [weak customView] in
      customView?.configure(model: $0)
    }
  }
}
