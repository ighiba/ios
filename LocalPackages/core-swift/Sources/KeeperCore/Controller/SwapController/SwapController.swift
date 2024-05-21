import Foundation
import TonSwift
import BigInt

public final class SwapController {
  
  actor State {
    var stonfiAssets = StonfiAssets()
    var stonfiPairs = StonfiPairs()
    
    func setStonfiAssets(_ stonfiAssets: StonfiAssets) {
      self.stonfiAssets = stonfiAssets
    }
    
    func setStonfiPairs(_ stonfiPairs: StonfiPairs) {
      self.stonfiPairs = stonfiPairs
    }
  }
  
  private var state = State()
  
  private let stonfiAssetsStore: StonfiAssetsStore
  private let stonfiPairsStore: StonfiPairsStore
  private let stonfiSwapService: StonfiSwapService
  private let stonfiAssetsLoader: StonfiAssetsLoader
  private let stonfiPairsLoader: StonfiPairsLoader
  private let stonfiMapper: StonfiMapper
  private let amountFormatter: AmountFormatter
  private let decimalAmountFormatter: DecimalAmountFormatter
  
  init(stonfiAssetsStore: StonfiAssetsStore,
       stonfiPairsStore: StonfiPairsStore,
       stonfiSwapService: StonfiSwapService,
       stonfiAssetsLoader: StonfiAssetsLoader,
       stonfiPairsLoader: StonfiPairsLoader,
       stonfiMapper: StonfiMapper,
       amountFormatter: AmountFormatter,
       decimalAmountFormatter: DecimalAmountFormatter) {
    self.stonfiAssetsStore = stonfiAssetsStore
    self.stonfiPairsStore = stonfiPairsStore
    self.stonfiSwapService = stonfiSwapService
    self.stonfiAssetsLoader = stonfiAssetsLoader
    self.stonfiPairsLoader = stonfiPairsLoader
    self.stonfiMapper = stonfiMapper
    self.amountFormatter = amountFormatter
    self.decimalAmountFormatter = decimalAmountFormatter
  }
  
  public func start() async {
    _ = await stonfiAssetsStore.addEventObserver(self) { [weak self] observer, event in
      guard let self else { return }
      switch event {
      case .didUpdateAssets(let assets):
        Task { await self.didUpdateAssets(assets) }
      }
    }
    
    _ = await stonfiPairsStore.addEventObserver(self) { [weak self] observer, event in
      guard let self else { return }
      switch event {
      case .didUpdatePairs(let pairs):
        Task { await self.didUpdatePairs(pairs) }
      }
    }
    
    await updateAssets()
    
    Task {
      await updatePairs()
    }
  }
  
  public func updateAssets() async {
    let assets = await stonfiAssetsStore.getAssets()
    await didUpdateAssets(assets)
  }
  
  public func updatePairs() async {
    let pairs = await stonfiPairsStore.getPairs()
    await didUpdatePairs(pairs)
  }
  
  public func getInitalSwapAsset() async -> SwapAsset? {
    let assets = await getStonfiAssets()
    guard let tonStonfiAsset = assets.items.first(where: { $0.isToncoin }) else { return nil }
    return stonfiMapper.mapStonfiAsset(tonStonfiAsset)
  }
  
  public func isPairExistsForAssets(_ assetOne: SwapAsset?, _ assetTwo: SwapAsset?) async -> Bool {
    guard let assetOne, let assetTwo else { return true }
    let pairs = await getStonfiPairs()
    return pairs.hasPair(keyOne: assetOne.contractAddress.toString(), keyTwo: assetTwo.contractAddress.toString())
  }
  
  public func simulateDirectSwap(sendAmount: BigUInt, sendAsset: SwapAsset, recieveAsset: SwapAsset) async throws -> SwapSimulationModel {
    let fromAddress = sendAsset.contractAddress
    let toAddress = recieveAsset.contractAddress
    
    let directSwapSimulation = try await stonfiSwapService.simulateDirectSwap(
      from: fromAddress,
      to: toAddress,
      offerAmount: sendAmount,
      slippageTolerance: "0.005", // TODO: slippage tolerance input
      referral: nil
    )
    
    return mapStonfiSwapSimulation(directSwapSimulation, sendAsset: sendAsset, recieveAsset: recieveAsset)
  }
  
  public func simulateReverseSwap(recieveAmount: BigUInt, sendAsset: SwapAsset, recieveAsset: SwapAsset) async throws -> SwapSimulationModel {
    let fromAddress = sendAsset.contractAddress
    let toAddress = recieveAsset.contractAddress
    
    let reverseSwapSimulation = try await stonfiSwapService.simulateReverseSwap(
      from: fromAddress,
      to: toAddress,
      askAmount: recieveAmount,
      slippageTolerance: "0.005", // TODO: slippage tolerance input
      referral: nil
    )
    
    return mapStonfiSwapSimulation(reverseSwapSimulation, sendAsset: sendAsset, recieveAsset: recieveAsset)
  }
  
  public func convertStringToAmount(string: String, targetFractionalDigits: Int) -> (value: BigUInt, fractionalDigits: Int) {
    guard !string.isEmpty else { return (0, targetFractionalDigits) }
    let fractionalSeparator: String = .fractionalSeparator ?? ""
    let components = string.components(separatedBy: fractionalSeparator)
    guard components.count < 3 else {
      return (0, targetFractionalDigits)
    }
    
    var fractionalDigits = 0
    if components.count == 2 {
        let fractionalString = components[1]
        fractionalDigits = fractionalString.count
    }
    let zeroString = String(repeating: "0", count: max(0, targetFractionalDigits - fractionalDigits))
    let bigIntValue = BigUInt(stringLiteral: components.joined() + zeroString)
    return (bigIntValue, targetFractionalDigits)
  }
  
  public func convertAmountToString(amount: BigUInt, fractionDigits: Int, maximumFractionDigits: Int? = nil) -> String {
    let newMaximumFractionDigits = maximumFractionDigits ?? fractionDigits
    return amountFormatter.formatAmount(
      amount,
      fractionDigits: fractionDigits,
      maximumFractionDigits: newMaximumFractionDigits
    )
  }
}

private extension SwapController {
  func didUpdateAssets(_ assets: StonfiAssets) async {
    await state.setStonfiAssets(assets)
  }
  
  func didUpdatePairs(_ pairs: StonfiPairs) async {
    await state.setStonfiPairs(pairs)
  }
  
  func getStonfiAssets() async -> StonfiAssets {
    let stateAssets = await state.stonfiAssets
    if stateAssets.isValid {
      return stateAssets
    } else {
      return await stonfiAssetsStore.getAssets()
    }
  }
  
  func getStonfiPairs() async -> StonfiPairs {
    let statePairs = await state.stonfiPairs
    if statePairs.isValid {
      return statePairs
    } else {
      return await stonfiPairsStore.getPairs()
    }
  }
  
  func mapStonfiSwapSimulation(_ stonfiSwapSimulation: StonfiSwapSimulation, sendAsset: SwapAsset, recieveAsset: SwapAsset) -> SwapSimulationModel {
    let offerAmount = convertAmountToString(amount: stonfiSwapSimulation.offerUnits, fractionDigits: sendAsset.fractionDigits)
    let askAmount = convertAmountToString(amount: stonfiSwapSimulation.askUnits, fractionDigits: recieveAsset.fractionDigits)
    let minAskAmount = convertAmountToString(amount: stonfiSwapSimulation.minAskUnits, fractionDigits: recieveAsset.fractionDigits, maximumFractionDigits: 4)
    let feeAmount  = convertAmountToString(amount: stonfiSwapSimulation.feeUnits, fractionDigits: recieveAsset.fractionDigits, maximumFractionDigits: 4)
    
    let swapRate = decimalAmountFormatter.format(amount: stonfiSwapSimulation.swapRate, maximumFractionDigits: 4)
    let priceImpact = decimalAmountFormatter.format(amount: stonfiSwapSimulation.priceImpact * 100, maximumFractionDigits: 3)
    
    return SwapSimulationModel(
      sendAmount: offerAmount,
      recieveAmount: askAmount,
      swapRate: SwapSimulationModel.Rate(value: swapRate),
      info: SwapSimulationModel.Info(
        priceImpact: priceImpact,
        minimumRecieved: minAskAmount,
        liquidityProviderFee: feeAmount,
        blockchainFee: "0.08 - 0.25 TON",
        route: SwapSimulationModel.Info.Route(
          tokenSymbolSend: sendAsset.symbol,
          tokenSymbolRecieve: recieveAsset.symbol
        ),
        providerName: "STON.fi"
      )
    )
  }
}

private extension StonfiAsset {
  var isToncoin: Bool {
    symbol == TonInfo.symbol && kind.uppercased() == "TON"
  }
}

private extension String {
  static let groupSeparator = " "
  static var fractionalSeparator: String? {
    Locale.current.decimalSeparator
  }
}