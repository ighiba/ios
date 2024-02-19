import UIKit
import TKUIKit
import TKCore
import KeeperCore

final class SettingsRootListItemsProvider: SettingsListItemsProvider {
  typealias WalletCellRegistration = UICollectionView.CellRegistration<WalletsListWalletCell, WalletsListWalletCell.Model>
  
  var didTapEditWallet: ((Wallet) -> Void)?
  var didTapCurrency: (() -> Void)?
  var didTapBackup: ((Wallet) -> Void)?
  var didTapSecurity: (() -> Void)?
  
  private let walletCellRegistration: WalletCellRegistration
  
  private let settingsController: SettingsController
  private let urlOpener: URLOpener
  private let appStoreReviewer: AppStoreReviewer
  
  init(settingsController: SettingsController,
       urlOpener: URLOpener,
       appStoreReviewer: AppStoreReviewer) {
    self.settingsController = settingsController
    self.appStoreReviewer = appStoreReviewer
    self.urlOpener = urlOpener
    let walletCellRegistration = WalletCellRegistration { cell, indexPath, itemIdentifier in
      cell.configure(model: itemIdentifier)
    }
    self.walletCellRegistration = walletCellRegistration
    
    settingsController.didUpdateActiveWallet = { [weak self] in
      self?.didUpdateSections?()
    }
    
    settingsController.didUpdateActiveCurrency = { [weak self] in
      self?.didUpdateSections?()
    }
  }
  
  var didUpdateSections: (() -> Void)?
  
  var title: String { "Settings" }
  
  func getSections() -> [SettingsListSection] {
    setupSettingsSections()
  }
  
  func selectItem(section: SettingsListSection, index: Int) {
    switch section.items[index] {
    case let walletModel as WalletsListWalletCell.Model:
      walletModel.selectionHandler?()
    default:
      break
    }
  }
  
  func cell(collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: AnyHashable) -> UICollectionViewCell? {
    switch itemIdentifier {
    case let model as WalletsListWalletCell.Model:
      let cell = collectionView.dequeueConfiguredReusableCell(using: walletCellRegistration, for: indexPath, item: model)
      return cell
    default: return nil
    }
  }
}

private extension SettingsRootListItemsProvider {
  func setupSettingsSections() -> [SettingsListSection] {
    [setupWalletSection(),
     SettingsListSection(
      padding: .sectionPadding,
      items: [
        setupSecurityItem(),
        setupBackupItem()
      ]
     ),
     SettingsListSection(
      padding: .sectionPadding,
      items: [
        setupCurrencyItem()
      ]
     ),
     SettingsListSection(
      padding: .sectionPadding,
      items: [
        setupSupportItem(),
        setupTonkeeperNewsItem(),
        setupContactUsItem(),
        setupRateItem(),
        setupDeleteAccountItem()
      ]
     ),
     SettingsListSection(
      padding: .sectionPadding,
      items: [
        setupLogoutItem()
      ]
     )
    ]
  }
  
  func setupWalletSection() -> SettingsListSection {
    let walletModel = settingsController.activeWalletModel()
    let cellContentModel = WalletsListWalletCellContentView.Model(
      emoji: walletModel.emoji,
      backgroundColor: .Tint.color(with: walletModel.colorIdentifier),
      walletName: walletModel.title,
      balance: "Edit name and color"
    )
    
    let cellModel = WalletsListWalletCell.Model(
      identifier: "wallet",
      accessoryType: .disclosureIndicator,
      selectionHandler: { [weak self] in
        guard let self = self else { return }
        self.didTapEditWallet?(self.settingsController.activeWallet())
      },
      cellContentModel: cellContentModel
    )
    
    return SettingsListSection(
      padding: NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16),
      items: [cellModel]
    )
  }
  
  func setupSecuritySection() -> SettingsSection {
    SettingsSection.settingsItems(items: [
      setupSecurityItem(),
      setupBackupItem()
    ])
  }
  
  func setupSecurityItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .securityItemTitle,
      selectionHandler: { [weak self] in
        self?.didTapSecurity?()
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .securityItemTitle,
        icon: .TKUIKit.Icons.Size28.key,
        tintColor: .Accent.blue
      )
    )
  }
  
  func setupBackupItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .backupItemTitle,
      selectionHandler: { [weak self] in
        guard let self = self else { return }
        self.didTapBackup?(self.settingsController.activeWallet())
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .backupItemTitle,
        icon: .TKUIKit.Icons.Size28.lock,
        tintColor: .Accent.blue
      )
    )
  }
  
  func setupCurrencyItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .currencyItemTitle,
      selectionHandler: { [weak self] in
        self?.didTapCurrency?()
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .currencyItemTitle,
        value: settingsController.activeCurrency().code
      )
    )
  }
  
  func setupSocialLinksSection() -> SettingsSection {
    SettingsSection.settingsItems(items: [
      setupSupportItem(),
      setupTonkeeperNewsItem(),
      setupContactUsItem(),
      setupRateItem(),
      setupDeleteAccountItem()
    ])
  }
  
  func setupSupportItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .logoutItemTitle,
      selectionHandler: { [weak self] in
        guard let self = self else { return }
        Task {
          guard let url = try await self.settingsController.supportURL else { return }
          await MainActor.run {
            self.urlOpener.open(url: url)
          }
        }
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .supportTitle,
        icon: .TKUIKit.Icons.Size28.telegram,
        tintColor: .Accent.blue
      )
    )
  }
  
  func setupTonkeeperNewsItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .tonkeeperNewsTitle,
      selectionHandler: { [weak self] in
        guard let self = self else { return }
        Task {
          guard let url = try await self.settingsController.tonkeeperNewsURL else { return }
          await MainActor.run {
            self.urlOpener.open(url: url)
          }
        }
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .tonkeeperNewsTitle,
        icon: .TKUIKit.Icons.Size28.telegram,
        tintColor: .Icon.secondary
      )
    )
  }
  
  func setupContactUsItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .contactUsTitle,
      selectionHandler: {  [weak self] in
        guard let self = self else { return }
        Task {
          guard let url = try await self.settingsController.contactUsURL else { return }
          await MainActor.run {
            self.urlOpener.open(url: url)
          }
        }
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .contactUsTitle,
        icon: .TKUIKit.Icons.Size28.messageBubble,
        tintColor: .Icon.secondary
      )
    )
  }
  
  func setupRateItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .rateTonkeeperXTitle,
      selectionHandler: { [weak self] in
        self?.appStoreReviewer.requestReview()
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .rateTonkeeperXTitle,
        icon: .TKUIKit.Icons.Size28.star,
        tintColor: .Icon.secondary
      )
    )
  }
  
  func setupDeleteAccountItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .deleteItemTitle,
      selectionHandler: { [weak self] in
        guard let self = self else { return }
        
        let actions = [
          UIAlertAction(title: .deleteDeleteButtonTitle, style: .destructive, handler: { _ in
          }),
          UIAlertAction(title: .deleteCancelButtonTitle, style: .cancel)
        ]
        
//        self.didShowAlert?(.deleteTitle, .deleteDescription, actions)
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .deleteItemTitle,
        icon: .TKUIKit.Icons.Size28.trashBin,
        tintColor: .Icon.secondary
      )
    )
  }
  
  func setupLogoutSection() -> SettingsSection {
    SettingsSection.settingsItems(items: [
      setupLogoutItem()
    ])
  }
  
  func setupLogoutItem() -> SettingsCell.Model {
    SettingsCell.Model(
      identifier: .logoutItemTitle,
      selectionHandler: {
        print("Log out")
      },
      cellContentModel: SettingsCellContentView.Model(
        title: .logoutItemTitle,
        icon: .TKUIKit.Icons.Size28.door,
        tintColor: .Accent.blue
      )
    )
  }
}

private extension String {
  static let securityItemTitle = "Security"
  
  static let backupItemTitle = "Backup"
  
  static let currencyItemTitle = "Currency"
  
  static let logoutItemTitle = "Sign Out"
  static let logoutTitle = "Log out?"
  static let logoutDescription = "This will erase keys to the wallet. Make sure you have backed up your secret recovery phrase."
  static let logoutCancelButtonTitle = "Cancel"
  static let logoutLogoutButtonTitle = "Log out"
  
  static let supportTitle = "Support"
  static let tonkeeperNewsTitle = "Tonkeeper news"
  static let contactUsTitle = "Contact us"
  static let rateTonkeeperXTitle = "Rate Tonkeeper X"
  static let legalTitle = "Legal"
  
  static let deleteItemTitle = "Delete account"
  static let deleteTitle = "Are you sure you want to delete your account?"
  static let deleteDescription = "This action will delete your account and all data from this application."
  static let deleteDeleteButtonTitle = "Delete account and data"
  static let deleteCancelButtonTitle = "Cancel"
}

private extension NSDirectionalEdgeInsets {
  static let sectionPadding = NSDirectionalEdgeInsets(
    top: 16,
    leading: 16,
    bottom: 16,
    trailing: 16
  )
}
