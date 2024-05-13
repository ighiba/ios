import UIKit
import TKCoordinator
import TKUIKit
import TKCore
import KeeperCore
import TonSwift
import TKLocalize

public final class CollectiblesCoordinator: RouterCoordinator<NavigationControllerRouter> {
  
  private weak var sendTokenCoordinator: SendTokenCoordinator?
  
  private let coreAssembly: TKCore.CoreAssembly
  private let keeperCoreMainAssembly: KeeperCore.MainAssembly
  
  public init(router: NavigationControllerRouter,
              coreAssembly: TKCore.CoreAssembly,
              keeperCoreMainAssembly: KeeperCore.MainAssembly) {
    self.coreAssembly = coreAssembly
    self.keeperCoreMainAssembly = keeperCoreMainAssembly
    super.init(router: router)
    router.rootViewController.tabBarItem.title = TKLocales.Tabs.purchases
    router.rootViewController.tabBarItem.image = .TKUIKit.Icons.Size28.purchase
  }
  
  public override func start() {
    openCollectibles()
  }
  
  public func handleTonkeeperDeeplink(deeplink: TonkeeperDeeplink) -> Bool {
    switch deeplink {
    case let .publish(model):
      if let sendTokenCoordinator = sendTokenCoordinator {
        return sendTokenCoordinator.handleTonkeeperPublishDeeplink(model: model)
      }
      return false
    default: return false
    }
  }
}

private extension CollectiblesCoordinator {
  func openCollectibles() {
    let module = CollectiblesAssembly.module(
      collectiblesController: keeperCoreMainAssembly.collectiblesController(), listModuleProvider: { [keeperCoreMainAssembly] wallet in
        CollectiblesListAssembly.module(
          collectiblesListController: keeperCoreMainAssembly.collectiblesListController(wallet: wallet)
        )
      }, emptyModuleProvider: { wallet in
        CollectiblesEmptyAssembly.module()
      })
    
    module.output.didSelectNFT = { [weak self] nft in
      self?.openNFTDetails(nft: nft)
    }
    
    router.push(viewController: module.view, animated: false)
  }
  
  func openNFTDetails(nft: NFT) {
    let module = CollectibleDetailsAssembly.module(
      collectibleDetailsController: keeperCoreMainAssembly.collectibleDetailsController(nft: nft),
      urlOpener: coreAssembly.urlOpener(),
      output: self
    )
    
    let navigationController = TKNavigationController(rootViewController: module.0)
    navigationController.configureDefaultAppearance()
    router.present(navigationController)
  }
}

extension CollectiblesCoordinator: CollectibleDetailsModuleOutput {
  func collectibleDetailsDidFinish(_ collectibleDetails: CollectibleDetailsModuleInput) {
    
  }
  
  func collectibleDetails(_ collectibleDetails: CollectibleDetailsModuleInput, transferNFT nft: NFT) {
    let navigationController = TKNavigationController()
    navigationController.configureDefaultAppearance()
    
    let sendTokenCoordinator = SendModule(
      dependencies: SendModule.Dependencies(
        coreAssembly: coreAssembly,
        keeperCoreMainAssembly: keeperCoreMainAssembly
      )
    ).createSendTokenCoordinator(
      router: NavigationControllerRouter(rootViewController: navigationController),
      sendItem: .nft(nft)
    )
    
    sendTokenCoordinator.didFinish = { [weak self, weak sendTokenCoordinator, weak navigationController] in
      self?.sendTokenCoordinator = nil
      navigationController?.dismiss(animated: true)
      guard let sendTokenCoordinator else { return }
      self?.removeChild(sendTokenCoordinator)
    }
    
    self.sendTokenCoordinator = sendTokenCoordinator
    
    addChild(sendTokenCoordinator)
    sendTokenCoordinator.start()
    
    self.router.rootViewController.presentedViewController?.present(navigationController, animated: true)
  }
}
