import Foundation

actor StonfiPairsStore {
  typealias ObservationClosure = (Event) -> Void
  
  enum Event {
    case didUpdatePairs(_ pairs: StonfiPairs)
  }
  
  private let service: StonfiPairsService
  private let repository: StonfiPairsRepository
  
  init(service: StonfiPairsService, repository: StonfiPairsRepository) {
    self.service = service
    self.repository = repository
  }
  
  func getPairs() async -> StonfiPairs {
    let storedPairs = (try? repository.getPairs()) ?? StonfiPairs()
    guard !storedPairs.isValid else { return storedPairs }
    
    do {
      return try await service.loadPairs()
    } catch {
      return storedPairs
    }
  }
  
  func setPairs(_ pairs: StonfiPairs) {
    try? repository.savePairs(pairs)
    observations.values.forEach { $0(.didUpdatePairs(pairs)) }
  }
  
  private var observations = [UUID: ObservationClosure]()
  
  func addEventObserver<T: AnyObject>(_ observer: T,
                                      closure: @escaping (T, Event) -> Void) -> ObservationToken {
    let id = UUID()
    let eventHandler: (Event) -> Void = { [weak self, weak observer] event in
      guard let self else { return }
      guard let observer else {
        Task { await self.removeObservation(key: id) }
        return
      }
      
      closure(observer, event)
    }
    observations[id] = eventHandler
    
    return ObservationToken { [weak self] in
      guard let self else { return }
      Task { await self.removeObservation(key: id) }
    }
  }
  
  func removeObservation(key: UUID) {
    observations.removeValue(forKey: key)
  }
}
