//
//  SettingsCurrencyPickerPresenter.swift
//  Tonkeeper

//  Tonkeeper
//  Created by Grigory Serebryanyy on 25/09/2023.
//

import Foundation
import WalletCore

final class SettingsCurrencyPickerPresenter {
  
  // MARK: - Module
  
  weak var viewInput: SettingsListViewInput?
  weak var output: SettingsListModuleOutput?
  
  // MARK: - Dependencies
  
  private let settingsController: SettingsController
  
  // MARK: - Mapper
  
  private let mapper = SettingsListItemMapper()
  
  // MARK: - Init
  
  init(settingsController: SettingsController) {
    self.settingsController = settingsController
  }
}

// MARK: - SettingsListPresenterIntput

extension SettingsCurrencyPickerPresenter: SettingsListPresenterInput {
  var isTitleLarge: Bool { false }
  var title: String { "Primary currency" }
  
  func viewDidLoad() {
    getCurrencies()
  }
}

// MARK: - SettingsListModuleInput

extension SettingsCurrencyPickerPresenter: SettingsListModuleInput {}

// MARK: - Private

private extension SettingsCurrencyPickerPresenter {
  func getCurrencies() {
    let allCurrencies = settingsController.getAvailableCurrencies()
    let selectedCurrency = (try? settingsController.getSelectedCurrency()) ?? .USD
    
    let items = allCurrencies.map { currency in
      let isSelected = currency == selectedCurrency
      return SettingsListItem(title: currency.code,
                              option: .plain(.init(accessory: isSelected ? .checkmark : .none,
                                                   handler: { [weak self] in
        try? self?.settingsController.setCurrency(currency)
        self?.getCurrencies()
      })))
    }
    
    let models = mapper.mapSettingsSections([SettingsListSection(items: items)])
    viewInput?.didUpdateSettings(models)
  }
}