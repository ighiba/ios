import Foundation

actor StonfiPairsStore {
  typealias ObservationClosure = (Event) -> Void
  
  enum Event {
    case didUpdatePairs(_ pairs: StonfiPairs)
  }
  
  private let repository: StonfiPairsRepository
  
  init(repository: StonfiPairsRepository) {
    self.repository = repository
  }
  
  func getPairs() -> StonfiPairs {
    do {
      return try repository.getPairs()
    } catch {
      return StonfiPairs()
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
