//
//  RoutineEntity.swift
//  Runner
//
//  Created by Francesco Arieti on 06/07/2026.
//

import AppIntents

struct RoutineEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Gym Routine"
    static var defaultQuery = RoutineQuery()
    
    // The hidden ID
    var id: String
    
    // The user-facing name
    @Property(title: "Name")
    var name: String

    init(id: String, name: String) {
      self.id = id
      self.name = name
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct RoutineQuery: EntityQuery {
  static let userDefaultsKey = "siri_routines"
  
  // Helper to read our synced JSON from UserDefaults
  private func fetchStoredRoutines() -> [RoutineEntity] {
    print("Saved shadow routines: \(UserDefaults.standard.object(forKey: Self.userDefaultsKey)) (in key \(Self.userDefaultsKey))")
    guard let dict = UserDefaults.standard.object(forKey: Self.userDefaultsKey) as? [String: String] else {
      return []
    }
    
    return dict.enumerated().compactMap { dict in
      let id = dict.element.key
      let name = dict.element.value
      return RoutineEntity(id: id, name: name)
    }
  }
  
  // Siri calls this to resolve specific IDs
  func entities(for identifiers: [RoutineEntity.ID]) async throws -> [RoutineEntity] {
    let allRoutines = fetchStoredRoutines()
    return allRoutines.filter { identifiers.contains($0.id) }
  }
  
  // Siri calls this to show a list of options in the Shortcuts App
  func suggestedEntities() async throws -> [RoutineEntity] {
    return fetchStoredRoutines()
  }
}

