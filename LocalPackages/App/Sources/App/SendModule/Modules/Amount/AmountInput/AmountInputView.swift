import UIKit
import TKUIKit
import SnapKit

class AmountInputView: UIView {
  
  let inputControl = AmountInputViewInputControl()
  
  let convertedButton: UIButton = {
    let button = UIButton(type: .custom)
    button.titleLabel?.font = TKTextStyle.body1.font
    button.titleLabel?.adjustsFontSizeToFitWidth = true
    button.titleLabel?.minimumScaleFactor = 0.5
    button.setTitleColor(.Text.secondary, for: .normal)
    button.setTitleColor(.Text.secondary.withAlphaComponent(0.48), for: .highlighted)
    button.layer.masksToBounds = true
    button.layer.borderWidth = .convertedButtonBorderWidth
    button.layer.borderColor = UIColor.Button.tertiaryBackground.cgColor
    button.contentEdgeInsets = .convertedButtonContentInsets
    return button
  }()
  
  let container = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    convertedButton.layoutIfNeeded()
    convertedButton.layer.cornerRadius = convertedButton.frame.height/2
  }
  
  func setup() {
    backgroundColor = .Background.content
    layer.cornerRadius = 16
    
    addSubview(container)
    container.addSubview(inputControl)
    container.addSubview(convertedButton)
    
    setupConstraints()
  }
  
  func setupConstraints() {
    container.snp.makeConstraints { make in
      make.left.right.equalTo(self)
      make.centerY.equalTo(self)
    }
    
    inputControl.snp.makeConstraints { make in
      make.top.equalTo(container)
      make.left.right.equalTo(container)
    }
    
    convertedButton.snp.makeConstraints { make in
      make.top.equalTo(inputControl.snp.bottom).offset(CGFloat.convertedButtonTopSpace)
      make.left.greaterThanOrEqualTo(container).offset(16)
      make.right.lessThanOrEqualTo(container).offset(-16)
      make.bottom.equalTo(container)
      make.centerX.equalTo(container)
    }
  }
}

private extension CGFloat {
  static let inputContainerSideSpacing: CGFloat = 40
  static let convertedButtonTopSpace: CGFloat = 10
  static let convertedButtonBorderWidth: CGFloat = 1.5
}

private extension UIEdgeInsets {
  static let convertedButtonContentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
}
