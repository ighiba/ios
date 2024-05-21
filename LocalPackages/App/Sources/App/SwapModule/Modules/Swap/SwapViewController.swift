import UIKit
import TKUIKit

final class SwapViewController: ModalViewController<SwapView, ModalNavigationBarView>, KeyboardObserving {
  
  private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(resignGestureAction))
    gestureRecognizer.cancelsTouchesInView = false
    return gestureRecognizer
  }()
  
  // MARK: - Dependencies
  
  private let viewModel: SwapViewModel
  
  // MARK: - Init
  
  init(viewModel: SwapViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    print("\(Self.self) deinit")
  }
  
  // MARK: - View Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    setupBindings()
    setupGestures()
    setupViewEvents()
    
    viewModel.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    registerForKeyboardEvents()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unregisterFromKeyboardEvents()
  }
  
  override func setupNavigationBarView() {
    super.setupNavigationBarView()
    
    customView.scrollView.contentInset.top = ModalNavigationBarView.defaultHeight
    
    customNavigationBarView.setupLeftBarItem(
      configuration: ModalNavigationBarView.BarItemConfiguration(
        view: customView.swapSettingsButton,
        contentAlignment: .center
      )
    )
    
    customNavigationBarView.setupCenterBarItem(
      configuration: ModalNavigationBarView.BarItemConfiguration(
        view: customView.titleView
      )
    )
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    guard let animationDuration = notification.keyboardAnimationDuration else { return }
    guard let keyboardHeight = notification.keyboardSize?.height else { return }
    
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
      self.customView.scrollView.contentInset.bottom = keyboardHeight
    }
  }
  
  public func keyboardWillHide(_ notification: Notification) {
    guard let animationDuration = notification.keyboardAnimationDuration else { return }
    
    UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut) {
      self.customView.scrollView.contentInset.bottom = 0
    }
  }
}

// MARK: - Setup

private extension SwapViewController {
  func setup() {
    view.backgroundColor = .Background.page
    customView.backgroundColor = .Background.page
    
    customView.swapSendContainerView.textField.delegate = viewModel.amountInpuTextFieldFormatter
    customView.swapRecieveContainerView.textField.delegate = viewModel.amountInpuTextFieldFormatter
  }
  
  func setupBindings() {
    viewModel.didUpdateModel = { [weak self] model in
      guard let customView = self?.customView else { return }
      
      customView.titleView.configure(model: .init(title: model.title))
      customView.swapSettingsButton.configuration.content.icon = .TKUIKit.Icons.Size16.sliders
      customView.swapButton.configuration.action = model.swapButton.action
    }
    
    viewModel.didUpdateStateModel = { [weak self] stateModel in
      guard let customView = self?.customView else { return }
      
      customView.swapSendContainerView.textField.textFieldState = stateModel.sendTextFieldState
      
      customView.actionButton.configuration.content.title = .plainString(stateModel.actionButton.title)
      customView.actionButton.configuration.isEnabled = stateModel.actionButton.isEnabled
      customView.actionButton.configuration.showsLoader = stateModel.actionButton.isActivity
      customView.actionButton.configuration.action = stateModel.actionButton.action
      customView.actionButton.configuration.backgroundColors = [
        .normal : stateModel.actionButton.backgroundColor,
        .highlighted : stateModel.actionButton.backgroundColorHighlighted,
        .disabled : stateModel.actionButton.backgroundColor
      ]
    }
    
    viewModel.didUpdateDetailsModel = { [weak self] detailsModel in
      guard let customView = self?.customView else { return }
      if let detailsModel {
        customView.swapDetailsContainerView.configure(model: detailsModel)
      }
      customView.isDetailsHidden = detailsModel == nil
    }
    
    viewModel.didUpdateAmountSend = { [weak self] amountSend in
      self?.customView.swapSendContainerView.textField.text = amountSend
    }
    
    viewModel.didUpdateAmountRecieve = { [weak self] amountRecieve in
      self?.customView.swapRecieveContainerView.textField.text = amountRecieve
    }
    
    viewModel.didUpdateSendTokenBalance = { [weak self] balanceTitle in
      self?.customView.swapSendContainerView.inputContainerView.setBalanceTitle(balanceTitle)
    }
    
    viewModel.didUpdateRecieveTokenBalance = { [weak self] balanceTitle in
      self?.customView.swapRecieveContainerView.inputContainerView.setBalanceTitle(balanceTitle)
    }
    
    viewModel.didUpdateSwapSendContainer = { [weak self] model in
      self?.customView.swapSendContainerView.configure(model: model)
    }
    
    viewModel.didUpdateSwapRecieveContainer = { [weak self] model in
      self?.customView.swapRecieveContainerView.configure(model: model)
    }
  }
  
  func setupGestures() {
    customView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  func setupViewEvents() {
    customView.swapSendContainerView.textField.didUpdateText = { [weak self] text in
      self?.viewModel.didInputAmountSend(text)
    }
    
    customView.swapRecieveContainerView.textField.didUpdateText = { [weak self] text in
      self?.viewModel.didInputAmountRecieve(text)
    }
  }
  
  @objc func resignGestureAction(sender: UITapGestureRecognizer) {
    customView.swapSendContainerView.textField.resignFirstResponder()
    customView.swapRecieveContainerView.textField.resignFirstResponder()
  }
}