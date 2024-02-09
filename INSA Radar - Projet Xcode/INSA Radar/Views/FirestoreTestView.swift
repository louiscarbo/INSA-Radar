//
//  FirestoreTestView.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 09/02/2024.
//

import SwiftUI
import FirebaseFirestore

struct FirestoreTestView: View {
    let db = Firestore.firestore()
    let presence = Presence(salle: "C1.10", people: 3, beginningTimestamp: Date())
        
    @State private var presences: [Presence] = []
    
    var body: some View {
        VStack {
            HStack {
                Button("Save") {
                    do {
                        try presence.addToDatabase()
                    } catch {
                        print("Oopsie")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            ForEach(presences) { presence in
                Text("Présence dans la salle : \(presence.salle)")
            }
            
        }
        .onAppear() {
            let presencesCollection = db.collection("presences")
            _ = presencesCollection.whereField("end_timestamp", isGreaterThanOrEqualTo: Timestamp(date: Date()))
                .addSnapshotListener { querySnapshot, error in
                    presences = []
                    guard let documents = querySnapshot?.documents else {
                        print("Error fetching documents: \(error!)")
                        return
                    }
                    for document in documents {
                        if let newPresence = try? document.data(as: Presence.self) {
                            presences.append(newPresence)
                        }
                    }
                    print("Mise à jour détectée")
                }
        }
        .onDisappear() {
            
        }
    }
}

#Preview {
    FirestoreTestView()
}
