//import TKUIKit
//
//final class MainViewKeyItemCell: TKCollectionViewNewCell {
//  let contentView = 
//}
//
//class HistoryCell: TKCollectionViewNewCell, TKConfigurableView {
//  let historyCellContentView = HistoryCellContentView()
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    setup()
//  }
//  
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }
//  
//  public override func contentSize(targetWidth: CGFloat) -> CGSize {
//    return historyCellContentView.sizeThatFits(CGSize(width: targetWidth, height: 0))
//  }
//  
//  public override func layoutSubviews() {
//    super.layoutSubviews()
//    historyCellContentView.frame = contentContainerView.bounds
//  }
//  
//  struct Configuration: Hashable {
//    let id: String
//    let historyContentConfiguration: HistoryCellContentView.Configuration
//  }
//  
//  func configure(configuration: Configuration) {
//    historyCellContentView.configure(configuration: configuration.historyContentConfiguration)
//    setNeedsLayout()
//  }
//  
//  override func prepareForReuse() {
//    super.prepareForReuse()
//    historyCellContentView.prepareForReuse()
//  }
//}
//
//private extension HistoryCell {
//  func setup() {
//    isSeparatorVisible = false
//    addSubview(historyCellContentView)
//  }
//}
