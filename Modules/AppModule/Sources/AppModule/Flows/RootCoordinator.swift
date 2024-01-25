import UIKit
import TKUIKit
import TKCoordinator
import TKCore
import KeeperCore
import OnboardingModule
import MainModule

final class RootCoordinator: RouterCoordinator<NavigationControllerRouter> {
  struct Dependencies {
    let coreAssembly: TKCore.CoreAssembly
    let keeperCoreRootAssembly: KeeperCore.RootAssembly
  }
  
  private let dependencies: Dependencies
  private let rootController: RootController

  init(router: NavigationControllerRouter,
       dependencies: Dependencies) {
    self.dependencies = dependencies
    self.rootController = dependencies.keeperCoreRootAssembly.rootController()
    super.init(router: router)
    router.rootViewController.setNavigationBarHidden(true, animated: false)
  }
  
  override func start() {
    switch rootController.getState() {
    case .onboarding:
      openOnboarding()
    case let .main(wallets, activeWallet):
      openMain(wallets: wallets, activeWallet: activeWallet)
    }
  }
}

private extension RootCoordinator {
  func openOnboarding() {
    let module = OnboardingModule(
      dependencies: OnboardingModule.Dependencies(
        coreAssembly: dependencies.coreAssembly,
        keeperCoreOnboardingAssembly: dependencies.keeperCoreRootAssembly.onboardingAssembly()
      )
    )
    let coordinator = module.createOnboardingCoordinator()
    
    coordinator.didFinishOnboarding = { [weak self, weak coordinator] in
      guard let coordinator = coordinator else { return }
      self?.removeChild(coordinator)
      self?.start()
    }
    
    addChild(coordinator)
    coordinator.start()
    
    showViewController(coordinator.router.rootViewController, animated: true)
  }
  
  func openMain(wallets: [Wallet], activeWallet: Wallet) {
    let mainAssemblyDependencies = MainAssembly.Dependencies(
      wallets: wallets, 
      activeWallet: activeWallet
    )
    let module = MainModule(
      dependencies: MainModule.Dependencies(
        coreAssembly: dependencies.coreAssembly,
        keeperCoreMainAssembly: dependencies.keeperCoreRootAssembly.mainAssembly(
          dependencies: mainAssemblyDependencies
        )
      )
    )
    let coordinator = module.createMainCoordinator()
    
    addChild(coordinator)
    coordinator.start()
    
    showViewController(coordinator.router.rootViewController, animated: true)
  }
  
  func showViewController(_ viewController: UIViewController, animated: Bool) {
    let containerViewController = UIViewController()
    containerViewController.addChild(viewController)
    containerViewController.view.addSubview(viewController.view)
    viewController.didMove(toParent: containerViewController)
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      viewController.view.topAnchor.constraint(equalTo: containerViewController.view.topAnchor),
      viewController.view.leftAnchor.constraint(equalTo: containerViewController.view.leftAnchor),
      viewController.view.bottomAnchor.constraint(equalTo: containerViewController.view.bottomAnchor),
      viewController.view.rightAnchor.constraint(equalTo: containerViewController.view.rightAnchor)
    ])
    router.setViewControllers([(containerViewController , nil)])
  }
}