//
//  ContentView.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import SwiftUI
import iCalendarParser

struct ContentView: View {
    @State private var salles: [Salle] = []
    
    @State private var buffering = false

    var body: some View {
        VStack {
            HStack {
                Button("Fetch Data BATC1") {
                    Task {
                        buffering = true
                        salles = try await getSallesAndEvents(from: "https://apps-int.insa-strasbourg.fr/ade/export.php?projectId=30&resources=5987")
                        buffering = false
                    }
                }
                Button("Fetch Data TOUSBATS") {
                    Task {
                        buffering = true
                        salles = try await getSallesAndEvents(from: "https://apps-int.insa-strasbourg.fr/ade/export.php?projectId=30&resources=5982,5987,5985,5988,5989,4360,5992,5990")
                        buffering = false
                    }
                }
            }
            if buffering {
                ProgressView()
                Spacer()
            } else {
                List {
                    ForEach(salles, id: \.identifier) { salle in
                        Text(salle.nom + " - \(salle.evenements.count) events")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
