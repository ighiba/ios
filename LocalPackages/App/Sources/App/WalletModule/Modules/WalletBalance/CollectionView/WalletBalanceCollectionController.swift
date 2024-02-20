import UIKit
import TKUIKit

final class WalletBalanceCollectionController: TKCollectionController<WalletBalanceSection, AnyHashable> {
  
  typealias BalanceCellRegistration = UICollectionView.CellRegistration<WalletBalanceBalanceItemCell, WalletBalanceBalanceItemCell.Model>
  typealias SetupSwitchCellRegistration = UICollectionView.CellRegistration<WalletBalanceSetupSwitchItemCell, WalletBalanceSetupSwitchItemCell.Model>
  typealias SetupPlainCellRegistration = UICollectionView.CellRegistration<WalletBalanceSetupPlainItemCell, WalletBalanceSetupPlainItemCell.Model>
  typealias SectionHeaderView = TKCollectionViewSupplementaryContainerView<TKListTitleView>
  
//  private let balanceCellRegistration: BalanceCellRegistration
//  private let switchCellRegistration: SwitchCellRegistration
  
  var finishSetupSectionHeaderModel: SectionHeaderView.Model?
  
  var didTapSectionHeaderButton: ((WalletBalanceSection) -> Void?)?
  
  init(collectionView: UICollectionView,
       headerViewProvider: (() -> UIView)? = nil, 
       footerViewProvider: (() -> UIView)? = nil) {
    let balanceCellRegistration = BalanceCellRegistration { cell, indexPath, itemIdentifier in
      cell.configure(model: itemIdentifier)
    }
//    self.balanceCellRegistration = balanceCellRegistration
    
    let setupSwitchCellRegistration = SetupSwitchCellRegistration { cell, indexPath, itemIdentifier in
      cell.configure(model: itemIdentifier)
    }
    let setupPlainCellRegistration = SetupPlainCellRegistration { cell, indexPath, itemIdentifier in
      cell.configure(model: itemIdentifier)
    }
    
//    self.
    
    super.init(
      collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
        switch itemIdentifier {
        case let model as WalletBalanceBalanceItemCell.Model:
          let cell = collectionView.dequeueConfiguredReusableCell(using: balanceCellRegistration, for: indexPath, item: model)
          cell.isFirstInSection = { return $0.item == 0 }
          cell.isLastInSection = { [unowned collectionView] in
            let numberOfItems = collectionView.numberOfItems(inSection: $0.section)
            return $0.item == numberOfItems - 1
          }
          return cell
        case let model as WalletBalanceSetupPlainItemCell.Model:
          let cell = collectionView.dequeueConfiguredReusableCell(using: setupPlainCellRegistration, for: indexPath, item: model)
          cell.isFirstInSection = { return $0.item == 0 }
          cell.isLastInSection = { [unowned collectionView] in
            let numberOfItems = collectionView.numberOfItems(inSection: $0.section)
            return $0.item == numberOfItems - 1
          }
          return cell
        case let model as WalletBalanceSetupSwitchItemCell.Model:
          let cell = collectionView.dequeueConfiguredReusableCell(using: setupSwitchCellRegistration, for: indexPath, item: model)
          cell.isFirstInSection = { return $0.item == 0 }
          cell.isLastInSection = { [unowned collectionView] in
            let numberOfItems = collectionView.numberOfItems(inSection: $0.section)
            return $0.item == numberOfItems - 1
          }
          return cell
        default: return nil
        }
      },
      headerViewProvider: headerViewProvider)
    
    collectionView.setCollectionViewLayout(TKCollectionLayout.layout(sectionLayout: { [weak self] sectionIndex in
      guard let self = self else { return nil }
      let section = dataSource.snapshot().sectionIdentifiers[sectionIndex]
      switch section {
      case .balanceItems:
        return balanceItemsSectionLayout()
      case .finishSetup:
        return finishSetupSectionLayout()
      }
    }), animated: false)
    
    supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
      guard let self = self else { return nil}
      switch WalletBalanceCollectionSupplementaryItem(rawValue: kind) {
      case .sectionHeader:
        let snapshot = self.dataSource.snapshot()
        let section = snapshot.sectionIdentifiers[indexPath.section]
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: SectionHeaderView.reuseIdentifier,
          for: indexPath
        ) as? SectionHeaderView
        
        if let model = self.finishSetupSectionHeaderModel {
          sectionHeaderView?.configure(model: model)
        }
        sectionHeaderView?.contentView.didTapButton = { [weak self] in
          self?.didTapSectionHeaderButton?(section)
        }
        return sectionHeaderView
      case .none: return nil
      }
    }
    
    collectionView.contentInset.bottom = 16
    
    collectionView.register(
      SectionHeaderView.self,
      forSupplementaryViewOfKind: WalletBalanceCollectionSupplementaryItem.sectionHeader.rawValue,
      withReuseIdentifier: SectionHeaderView.reuseIdentifier
    )
    
    var snapshot = dataSource.snapshot()
    snapshot.appendSections([.balanceItems])
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  func setBalanceItems(_ items: [AnyHashable]) {
    var snapshot = dataSource.snapshot()
    snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .balanceItems))
    snapshot.appendItems(items, toSection: .balanceItems)
    snapshot.reloadSections([.balanceItems])
    UIView.performWithoutAnimation {
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
  
  func setFinishSetupSection(_ items: [AnyHashable],
                             headerModel: SectionHeaderView.Model) {
    self.finishSetupSectionHeaderModel = headerModel
    var snapshot = dataSource.snapshot()
    snapshot.deleteSections([.finishSetup])
    if !items.isEmpty {
      snapshot.appendSections([.finishSetup])
      snapshot.appendItems(items, toSection: .finishSetup)
      snapshot.reloadSections([.finishSetup])
    }
    UIView.performWithoutAnimation {
      dataSource.apply(snapshot, animatingDifferences: true)
    }
  }
}

private extension WalletBalanceCollectionController {
  func dequeueSupplementaryView(collectionView: UICollectionView,
                                kind: String,
                                indexPath: IndexPath) -> UICollectionReusableView? {
    switch WalletBalanceCollectionSupplementaryItem(rawValue: kind) {
    case .sectionHeader:
      let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: SectionHeaderView.reuseIdentifier,
        for: indexPath
      )
      guard let model = finishSetupSectionHeaderModel else { return nil }
      (sectionHeaderView as? SectionHeaderView)?.configure(model: model)
      return sectionHeaderView

    case .none: return nil
    }
  }
  
  func balanceItemsSectionLayout() -> NSCollectionLayoutSection {
    return TKCollectionLayout.listSectionLayout(
      padding: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16),
      heightDimension: .absolute(76))
  }
  
  func finishSetupSectionLayout() -> NSCollectionLayoutSection {
    let section = TKCollectionLayout.listSectionLayout(
      padding: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16),
      heightDimension: .absolute(76))
    
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(56)
    )
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: HistoryListSupplementaryItem.sectionHeader.rawValue,
      alignment: .top
    )
    section.boundarySupplementaryItems = [header]
    
    return section
  }
}