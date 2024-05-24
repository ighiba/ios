import UIKit
import TKUIKit

final class SwapAmountInputView: UIView, ConfigurableView {
  
  let tokenButton = SwapTokenButton()
  let textField = PlainTextField()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let tokenButtonFrame = CGRect(origin: .zero, size: tokenButton.sizeThatFits(bounds.size))
    tokenButton.frame = tokenButtonFrame
  }
  
  struct Model {
    typealias Icon = SwapTokenButton.Model.Icon
    
    struct TokenButton {
      let title: String
      let icon: Icon
      let action: (() -> Void)?
    }
    
    struct TextField {
      let isEnabled: Bool
      var inputText: String? = nil
    }
    
    let tokenButton: TokenButton
    let textField: TextField
  }
  
  func configure(model: Model) {
    tokenButton.configure(
      model: SwapTokenButtonContentView.Model(
        title: model.tokenButton.title.withTextStyle(.label1, color: .Button.tertiaryForeground),
        icon: model.tokenButton.icon
      )
    )
    
    tokenButton.addTapAction {
      model.tokenButton.action?()
    }
    
    textField.isEnabled = model.textField.isEnabled
    if let inputText = model.textField.inputText {
      textField.text = inputText
    }
    
    setNeedsLayout()
  }
}

private extension SwapAmountInputView {
  func setup() {
    textField.text = "0"
    textField.font = TKTextStyle.num2.font
    textField.textColor = .Text.primary
    textField.textAlignment = .right
    
    addSubview(tokenButton)
    addSubview(textField)
    
    setupConstraints()
  }
  
  func setupConstraints() {
    textField.snp.makeConstraints { make in
      make.left.equalTo(tokenButton.snp.right).offset(CGFloat.horizontalSpacing)
      make.right.equalTo(self)
      make.height.equalTo(CGFloat.itemHeight)
      make.centerY.equalTo(tokenButton)
    }
  }
}

private extension CGFloat {
  static let itemHeight: CGFloat = 36
  static let horizontalSpacing: CGFloat = 8
}

public class PlainTextField: UITextField {
  
  public enum TextFieldState {
    case inactive
    case active
    case error
    
    var textColor: UIColor {
      switch self {
      case .inactive:
        return .Text.tertiary
      case .active:
        return .Text.primary
      case .error:
        return .Accent.red
      }
    }
  }
  
  public var didUpdateText: ((String) -> Void)?
  public var didBeginEditing: (() -> Void)?
  public var didEndEditing: (() -> Void)?
  
  public var textFieldState: TextFieldState = .inactive {
    didSet {
      didUpdateTextFieldState()
    }
  }
  
  public override var isEnabled: Bool {
    didSet {
      textFieldState = isEnabled ? .active : .inactive
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .clear
    font = TKTextStyle.num2.font
    textColor = .Text.primary
    tintColor = .Accent.blue
    keyboardType = .decimalPad
    autocapitalizationType = .none
    autocorrectionType = .no
    keyboardAppearance = .dark
    
    addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
    addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
  }
  
  @objc func editingChanged() {
    didUpdateText?(text ?? "")
  }
  
  @objc func editingDidBegin() {
    didBeginEditing?()
  }
  
  @objc func editingDidEnd() {
    didEndEditing?()
  }
  
  private func didUpdateTextFieldState() {
    if isEnabled {
      textColor = textFieldState.textColor
    } else {
      textColor = TextFieldState.inactive.textColor
    }
  }
}
