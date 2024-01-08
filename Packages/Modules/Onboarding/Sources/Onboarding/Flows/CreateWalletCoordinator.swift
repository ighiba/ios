import UIKit
import TKCoordinator
import TKUIKit
import TKScreenKit
import Passcode

public final class CreateWalletCoordinator: RouterCoordinator<NavigationControllerRouter> {
  
  var didCancel: (() -> Void)?
  var didCreateWallet: (() -> Void)?
  
  public override func start() {
    openCreatePasscode()
  }
}

private extension CreateWalletCoordinator {
  func openCreatePasscode() {
    let coordinator = Passcode().createCreatePasscodeCoordinator(router: router)
    
    coordinator.didCancel = { [weak self, weak coordinator] in
      guard let coordinator = coordinator else { return }
      self?.removeChild(coordinator)
      self?.didCancel?()
    }
    
    coordinator.didCreatePasscode = { [weak self, weak coordinator] passcode in
      guard let coordinator = coordinator else { return }
      self?.removeChild(coordinator)
    }
    
    addChild(coordinator)
    coordinator.start()
  }
}
