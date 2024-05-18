import UIKit
import TKUIKit
import KeeperCore

struct SwapTokenListModel {
  struct Button {
    let title: String
    let action: (() -> Void)?
  }
  
  let title: String
  let noSearchResultsTitle: String
  let closeButton: Button
}

protocol SwapTokenListModuleOutput: AnyObject {
  var didTapCloseButton: (() -> Void)? { get set }
  var didChooseToken: (() -> Void)? { get set }
}

protocol SwapTokenListModuleInput: AnyObject {
  
}

protocol SwapTokenListViewModel: AnyObject {
  var didUpdateModel: ((SwapTokenListModel) -> Void)? { get set }
  var didUpdateListItems: (([SuggestedTokenCell.Configuration], [TKUIListItemCell.Configuration]) -> Void)? { get set }
  var didUpdateSearchResultsItems: (([TKUIListItemCell.Configuration]) -> Void)? { get set }
  
  func viewDidLoad()
  func reloadListItems()
  func didInputSearchText(_ searchText: String)
  func didSelectToken(_ symbol: String)
}

final class SwapTokenListViewModelImplementation: SwapTokenListViewModel, SwapTokenListModuleOutput, SwapTokenListModuleInput {

  // MARK: - SwapTokenListModuleOutput
  
  var didTapCloseButton: (() -> Void)?
  var didChooseToken: (() -> Void)?
  
  // MARK: - SwapTokenListModuleInput
  
  
  // MARK: - SwapTokenListViewModel
  
  var didUpdateModel: ((SwapTokenListModel) -> Void)?
  var didUpdateListItems: (([SuggestedTokenCell.Configuration], [TKUIListItemCell.Configuration]) -> Void)?
  var didUpdateSearchResultsItems: (([TKUIListItemCell.Configuration]) -> Void)?
  
  func viewDidLoad() {
    update()
    
    swapTokenListController.didUpdateListItems = { [weak self] tokenButtonListItemsModel, tokenListItemsModel in
      guard let self else { return }
      
      let suggestedItems = tokenButtonListItemsModel.items.map { item in
        self.itemMapper.mapTokenButtonListItem(item) {
          self.didSelectToken(item.symbol)
        }
      }
      
      let otherItems = tokenListItemsModel.items.map { item in
        self.itemMapper.mapTokenListItem(item) {
          self.didSelectToken(item.symbol)
        }
      }
      
      self.didUpdateListItems?(suggestedItems, otherItems)
    }
    
    swapTokenListController.didUpdateSearchResultsItems = { [weak self] tokenListItemsModel in
      guard let self else { return }
      
      let searchResultsItems = tokenListItemsModel.items.map { item in
        self.itemMapper.mapTokenListItem(item) {
          self.didSelectToken(item.symbol)
        }
      }
      
      self.didUpdateSearchResultsItems?(searchResultsItems)
    }
    
    Task {
      await swapTokenListController.start()
    }
  }
  
  func reloadListItems() {
    Task {
      await swapTokenListController.updateListItems()
    }
  }
  
  func didInputSearchText(_ searchText: String) {
    swapTokenListController.performSearch(with: searchText)
  }
  
  func didSelectToken(_ symbol: String) {
    print(symbol)
  }
  
  // MARK: - State
  
  private var isResolving = false {
    didSet {
      guard isResolving != oldValue else { return }
      update()
    }
  }
  
  // MARK: - Mapper
  
  private let itemMapper = SwapTokenListItemMapper()
  
  // MARK: - Dependencies
  
  private let swapTokenListController: SwapTokenListController
  
  // MARK: - Init
  
  init(swapTokenListController: SwapTokenListController) {
    self.swapTokenListController = swapTokenListController
  }
  
  deinit {
    print("\(Self.self) deinit")
  }
}

// MARK: - Private

private extension SwapTokenListViewModelImplementation {
  func update() {
    let model = createModel()
    didUpdateModel?(model)
  }
  
  func createModel() -> SwapTokenListModel {
    SwapTokenListModel(
      title: "Choose Token",
      noSearchResultsTitle: "Your search returned no results",
      closeButton: SwapTokenListModel.Button(
        title: "Close",
        action: { [weak self] in
          self?.didTapCloseButton?()
        }
      )
    )
  }
}
