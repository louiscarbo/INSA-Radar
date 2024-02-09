//
//  SalleView.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 09/02/2024.
//

import SwiftUI

struct SalleView: View {
    let salle: String
    
    @State private var presences: [Presence] = []
    @State private var peoplePresent: Int = 0
    private var displayedText: String {
        switch peoplePresent {
        case 0: "Personne n'a déclaré sa présence dans la salle actuellement."
        case 1: "Il y a une personne dans la salle actuellement."
        default: "Il y a actuellement \(peoplePresent) personnes dans la salle."
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(displayedText)
                    .font(.title)
            }
            .navigationTitle(salle)
        }
        .onAppear {
            PresenceManager.shared.addListenerForCurrentPresences(for: salle) { presences in
                withAnimation {
                    self.presences = presences
                }
            }
        }
        .onDisappear {
            PresenceManager.shared.removeListenerforCurrentPresences(for: salle)
        }
        .onChange(of: presences) {
            countPeoplePresent()
        }
    }
    
    private func countPeoplePresent() {
        peoplePresent = presences.reduce(0) { $0 + $1.people }
    }
}

#Preview {
    Text("Hi")
        .sheet(isPresented: .constant(true), content: {
            SalleView(salle: "C1.10")
        })
}
