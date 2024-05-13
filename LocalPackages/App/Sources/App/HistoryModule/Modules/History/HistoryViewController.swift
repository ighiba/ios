import UIKit
import TKUIKit
import TKCoordinator
import TKLocalize

final class HistoryViewController: GenericViewViewController<HistoryView>, ScrollViewController {
  private let viewModel: HistoryViewModel
  
  private var emptyViewController: UIViewController?
  private var listViewController: HistoryListViewController?
  
  init(viewModel: HistoryViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
    setupBindings()
    viewModel.viewDidLoad()
    
    customView.showList()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    listViewController?.customView.collectionView.contentInset.top = customView.navigationBarView.additionalInset
    listViewController?.customView.collectionView.verticalScrollIndicatorInsets.top = customView.navigationBarView.additionalInset
  }
  
  func scrollToTop() {
    listViewController?.scrollToTop()
  }
}

// MARK: - Private

private extension HistoryViewController {
  func setup() {
    customView.navigationBarView.title = TKLocales.History.title
  }
  
  func setupBindings() {
    viewModel.didUpdateEmptyViewController = { [weak self] viewController in
      self?.setupEmptyViewController(viewController: viewController)
    }
    
    viewModel.didUpdateListViewController = { [weak self] viewController in
      self?.setupListViewController(viewController: viewController)
    }
    
    viewModel.didUpdateIsEmpty = { [weak self] isEmpty in
      isEmpty ? self?.customView.showEmptyState() : self?.customView.showList()
      self?.customView.navigationBarView.isHidden = isEmpty
    }
    
    viewModel.didUpdateIsConnecting = { [weak self] isConnecting in
      self?.customView.navigationBarView.isConnecting = isConnecting
    }
  }
  
  func setupEmptyViewController(viewController: UIViewController) {
    self.emptyViewController?.removeFromParent()
    self.emptyViewController = viewController
    addChild(viewController)
    customView.addEmptyContentView(view: viewController.view)
    viewController.didMove(toParent: self)
  }
  
  func setupListViewController(viewController: HistoryListViewController) {
    self.listViewController?.removeFromParent()
    self.listViewController = viewController
    addChild(viewController)
    customView.addListContentView(view: viewController.view)
    viewController.didMove(toParent: self)
    
    DispatchQueue.main.async {
      self.customView.navigationBarView.scrollView = self.listViewController?.customView.collectionView
    }
  }
}

