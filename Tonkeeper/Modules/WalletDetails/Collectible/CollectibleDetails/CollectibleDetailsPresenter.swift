//
//  CollectibleDetailsCollectibleDetailsPresenter.swift
//  Tonkeeper

//  Tonkeeper
//  Created by Grigory Serebryanyy on 21/08/2023.
//

import Foundation
import WalletCore

final class CollectibleDetailsPresenter {
  
  // MARK: - Module
  
  weak var viewInput: CollectibleDetailsViewInput?
  weak var output: CollectibleDetailsModuleOutput?
  
  // MARK: - Dependencies
  
  private let collectibleDetailsController: CollectibleDetailsController
  
  init(collectibleDetailsController: CollectibleDetailsController) {
    self.collectibleDetailsController = collectibleDetailsController
  }
}

// MARK: - CollectibleDetailsPresenterIntput

extension CollectibleDetailsPresenter: CollectibleDetailsPresenterInput {
  func viewDidLoad() {
    updateView()
  }
  
  func didTapSwipeButton() {
    output?.collectibleDetailsDidFinish(self)
  }
}

// MARK: - CollectibleDetailsModuleInput

extension CollectibleDetailsPresenter: CollectibleDetailsModuleInput {}

// MARK: - Private

private extension CollectibleDetailsPresenter {
  func updateView() {
    let listItems: [ModalContentViewController.Configuration.ListItem] = [
      .init(left: "Owner", rightTop: .value("EQCc…G21L"), rightBottom: .value(nil)),
      .init(left: "Contract address", rightTop: .value("EQAK…OREO"), rightBottom: .value(nil))
    ]
    let model = CollectibleDetailsDetailsView.Model(titleViewModel: .init(title: "Details"),
                                                    buttonTitle: "View in explorer",
                                                    listViewModel: listItems)
    viewInput?.updateDetailsSection(model: model)
    
    let descriptionModel = CollectibleDetailsCollectionDescriptionView.Model(title: "About Eggs Wisdom", description: desc)
    viewInput?.updateContentSection(model: descriptionModel)
    
    
    let collectibleModel = CollectibleDetailsCollectibleView.Model(title: "Dragons Avatar", subtitle: "Domestic Dragons", description: desc, imageURL: URL(string: "https://cache.tonapi.io/imgproxy/Z9k3r26OkIQaB7TIKrorHuYvc-sNEYZHzm8jiZQiHoo/rs:fill:1500:1500:1/g:no/aHR0cHM6Ly9zLmdldGdlbXMuaW8vbmZ0L2MvNjNiYWU2NjUzM2UxMWIyODFmNDdkMWFkLzE1NjgvaW1hZ2UucG5n.webp")!)
    viewInput?.updateCollectibleSection(model: collectibleModel)
    
    viewInput?.updateTitle("Egg #1569")
    
    
    let carousel = CollectibleDetailsPropertiesСarouselView.Model(titleModel: .init(title: "Properties"), propertiesModels: [
      .init(title: "Size", value: "Small"),
      .init(title: "Background", value: "Blur"),
      .init(title: "Blur", value: "Background"),
      .init(title: "Color", value: "Orange"),
    ])
    
    viewInput?.updatePropertiesSection(model: carousel)
  }
}

let desc = """
Contests, gifts, auctions on our channel @EggsWisdom . We have established a gift fund with over 375 Telegram Usernames 💎, which we will give away to the winners of upcoming auctions free of charge.\n\nOur NFT Eggs project is planning to pursue more ambitious ideas, and we would like to give you a glimpse of what's to come.\n\nThe value of our NFTs Eggs will gradually increase as they become associated with Telegram Usernames, and we anticipate that they could appreciate by a factor of 5x to 100x⬆ their original value.\n\nIn the future, we will offer custom-designed NFTs Eggs as gifts with a unique theme of your choice.\n\nThank you for your continued support!🤝\n\nTelegram @EggsWisdom
"""
