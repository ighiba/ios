import UIKit
import TKUIKit

final class MainView: UIView {
  
  let buttonsView = MainHeaderButtonsView()
  let collectionView = TKUICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewLayout()
  )
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension MainView {
  func setup() {
    backgroundColor = .Background.page
    collectionView.backgroundColor = .Background.page
    addSubview(collectionView)

    setupConstraints()
  }
  
  func setupConstraints() {
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: topAnchor),
      collectionView.leftAnchor.constraint(equalTo: leftAnchor),
      collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
      collectionView.rightAnchor.constraint(equalTo: rightAnchor)
    ])
  }
}
