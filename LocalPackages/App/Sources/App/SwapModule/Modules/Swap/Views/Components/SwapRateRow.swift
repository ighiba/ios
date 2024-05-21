import UIKit
import TKUIKit

final class SwapRateRow: UIView, ConfigurableView {
  
  let swapRateLabel = UILabel()
  let loaderView = TKLoaderView(size: .small, style: .secondary)
  
  override var intrinsicContentSize: CGSize { sizeThatFits(bounds.size) }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width, height: .rowHeight)
  }
  
  struct Model {
    let swapRate: NSAttributedString
  }
  
  func configure(model: Model) {
    swapRateLabel.attributedText = model.swapRate
  }
}

private extension SwapRateRow {
  func setup() {
    loaderView.isLoading = true
    
    addSubview(swapRateLabel)
    addSubview(loaderView)
    
    setupConstraints()
  }
  
  func setupConstraints() {
    loaderView.setContentHuggingPriority(.required, for: .horizontal)
    
    swapRateLabel.snp.makeConstraints { make in
      make.left.equalTo(self).offset(CGFloat.horizontalPadding)
      make.right.equalTo(loaderView.snp.left)
      make.centerY.equalTo(self)
    }
    
    loaderView.snp.makeConstraints { make in
      make.right.equalTo(self).inset(CGFloat.horizontalPadding)
      make.centerY.equalTo(self)
    }
  }
}

private extension CGFloat {
  static let horizontalPadding: CGFloat = 16
  static let rowHeight: CGFloat = 48
}