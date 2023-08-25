//
//  ActivityRootActivityRootProtocols.swift
//  Tonkeeper

//  Tonkeeper
//  Created by Grigory Serebryanyy on 06/06/2023.
//

import Foundation
import TonSwift

protocol ActivityRootModuleOutput: AnyObject {
  func didTapReceiveButton()
  func didSelectTransaction()
  func didSelectCollectible(address: Address)
}

protocol ActivityRootModuleInput: AnyObject {}

protocol ActivityRootPresenterInput {
  func viewDidLoad()
}

protocol ActivityRootViewInput: AnyObject {
  func showEmptyState()
  func updateTitle(_ title: String)
}
