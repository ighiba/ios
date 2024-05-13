import UIKit
import TKUIKit
import TKCore
import KeeperCore
import TKLocalize

final class SettingsSecurityListItemsProvider: SettingsListItemsProvider {
  
  var didRequireConfirmation: (() async -> Bool)?
  var didTapChangePasscode: (() -> Void)?
  
  private let settingsSecurityController: SettingsSecurityController
  private let biometryAuthentificator: BiometryAuthentificator

  init(settingsSecurityController: SettingsSecurityController,
       biometryAuthentificator: BiometryAuthentificator) {
    self.settingsSecurityController = settingsSecurityController
    self.biometryAuthentificator = biometryAuthentificator
  }
  
  var didUpdateSections: (() -> Void)?
  
  var title: String { .title }
  
  func getSections() async -> [SettingsListSection] {
    await setupSettingsSections()
  }
  
  func cell(collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: AnyHashable) -> UICollectionViewCell? {
    nil
  }
  
  func selectItem(section: SettingsListSection, index: Int) {}
}

private extension SettingsSecurityListItemsProvider {
  func setupSettingsSections() async -> [SettingsListSection] {
    [
      await createBiometrySection(),
      createBiometryDescriptionSection(),
      createPasscodeSection()
    ]
  }
  
  func createBiometrySection() async -> SettingsListSection {
    let isBiometryEnabled = await settingsSecurityController.isBiometryEnabled
    
    let switchModel: TKListItemSwitchView.Model = {
      let isOn: Bool
      let isEnabled: Bool
      
      let result = biometryAuthentificator.canEvaluate(policy: .deviceOwnerAuthenticationWithBiometrics)
      switch result {
      case .success:
        isOn = isBiometryEnabled
        isEnabled = true
      case .failure:
        isOn = false
        isEnabled = false
      }
      return TKListItemSwitchView.Model(
        isOn: isOn,
        isEnabled: isEnabled,
        action: { [weak self] isOn in
          guard let self else { return !isOn }
          if isOn {
            let isConfirmed = (await self.didRequireConfirmation?()) ?? false
            guard isConfirmed else { return !isOn }
          }
          return await settingsSecurityController.setIsBiometryEnabled(isOn)
        }
      )
    }()
    
    let title: String
    switch biometryAuthentificator.biometryType {
    case .touchID:
      title = TKLocales.Security.use(String.touchId)
    case .faceID:
      title = TKLocales.Security.use(String.faceId)
    default:
      title = .biometryUnavailable
    }
    
    return SettingsListSection(
      padding: NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 0, trailing: 16),
      items: [
        SettingsCell.Model(
          identifier: "biometry",
          isHighlightable: false,
          cellContentModel: SettingsCellContentView.Model(
            title: title,
            switchValue: switchModel
          )
        )
      ]
    )
  }
  
  func createBiometryDescriptionSection() -> SettingsListSection {
    SettingsListSection(
      padding: NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16),
      items: [
        SettingsTextCell.Model(
          id: "biometry_description",
          padding: .zero,
          text: String.biometryDescription.withTextStyle(
            .body2,
            color: .Text.secondary,
            alignment: .left,
            lineBreakMode: .byWordWrapping
          ),
          numberOfLines: 0
        )
      ]
    )
  }
  
  func createPasscodeSection() -> SettingsListSection {
    SettingsListSection(
      padding: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
      items: [
        SettingsCell.Model(
          identifier: "change_passcode",
          selectionHandler: { [weak self] in
            self?.didTapChangePasscode?()
          },
          cellContentModel: SettingsCellContentView.Model(
            title: .changePasscodeTitle,
            icon: .TKUIKit.Icons.Size28.lock,
            tintColor: .Accent.blue
          )
        )
      ]
    )
  }
}

private extension String {
  static let title = TKLocales.Security.title
  static let use = TKLocales.Security.use
  static let faceId = "Face ID"
  static let touchId = "Touch ID"
  static let biometryUnavailable = TKLocales.Security.unavailable_error
  static let biometryDescription = TKLocales.Security.use_biometry_description
  
  static let changePasscodeTitle = TKLocales.Security.change_passcode
}
