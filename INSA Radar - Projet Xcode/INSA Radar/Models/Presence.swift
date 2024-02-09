//
//  Presence.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 08/02/2024.
//

import Foundation
import FirebaseFirestore

final class Presence: Identifiable, Observable, Codable, Equatable {
    @DocumentID
    var id: String?
    var salle: String
    var people: Int
    var endTimestamp: Date
    var beginningTimestamp: Date = Date()
    
    init(salle: String, people: Int, beginningTimestamp: Date) {
        self.salle = salle
        self.people = people
        self.endTimestamp = beginningTimestamp.addingTimeInterval(3600*4)
        self.beginningTimestamp = beginningTimestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "presence_id"
        case salle
        case people
        case endTimestamp = "end_timestamp"
        case beginningTimestamp = "beginning_timestamp"
    }
    
    func addToDatabase() throws {
        let db = Firestore.firestore()
        let presencesCollection = db.collection("presences")
        do {
            let newPresence = try presencesCollection.addDocument(from: self)
            print("Presence stored with new document reference: \(newPresence)")
        }
    }
    
    static func == (lhs: Presence, rhs: Presence) -> Bool {
        return
            lhs.id == rhs.id &&
            lhs.salle == rhs.salle &&
            lhs.people == rhs.people &&
            lhs.endTimestamp == rhs.endTimestamp &&
            lhs.beginningTimestamp == rhs.beginningTimestamp
    }
}

// MARK: PresenceManager
final class PresenceManager {
    private init() {}
    
    private var currentPresencesListeners: [String: ListenerRegistration?] = [:]
    
    static let shared = PresenceManager()
    
    func addListenerForCurrentPresences(for salle: String, completion: @escaping (_ presences: [Presence]) -> Void) {
        
        let db = Firestore.firestore()
        let presencesInSalle = db.collection("presences")
            .whereField("salle", isEqualTo: salle)
            .whereField("end_timestamp", isGreaterThanOrEqualTo: Timestamp(date: Date()))
        let listener = presencesInSalle.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            
            let presences: [Presence] = documents.compactMap { documentSnapshot in
                return try? documentSnapshot.data(as: Presence.self)
            }
            
            completion(presences)
        }
        
        self.currentPresencesListeners.updateValue(listener, forKey: salle)
    }
    
    func removeListenerforCurrentPresences(for salle: String) {
        if let listener = self.currentPresencesListeners[salle] {
            listener?.remove()
        }
    }
}


