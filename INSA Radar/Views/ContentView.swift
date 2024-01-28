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
    @State private var availableSalles: [Salle] = []
    @State private var notAvailableSalles: [Salle] = []
    
    @State private var date: Date = Date()
    @State private var showInformations = false
    
    @State private var buffering = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Voir les salles disponibles le", selection: $date)
                        .onChange(of: date) {
                            refreshDate()
                        }
                }
                if buffering {
                    HStack {
                        Text("En train de récupérer les informations depuis l'emploi du temps...")
                        ProgressView()
                    }
                        
                } else {
                    if availableSalles.count > 0 {
                        Section("Salles disponibles") {
                            ForEach(availableSalles, id: \.identifier) { salle in
                                AvailableSalleView(date: date, salle: salle)
                            }
                        }
                    }
                    if notAvailableSalles.count > 0 {
                        Section("Salles non disponibles") {
                            ForEach(notAvailableSalles, id: \.identifier) { salle in
                                Text(salle.nom + " - \(salle.evenements.count) events")
                            }
                        }
                    }
                    if availableSalles.count == 0 && notAvailableSalles.count == 0 {
                        Text("Rafraîchissez l'application à l'aide du bouton en haut de l'écran.")
                    }
                }
            }
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem {
                    Button {
                        refresh()
                    } label: {
                        Label("Rafraîchir", systemImage: "arrow.clockwise")
                    }
                }
                ToolbarItem {
                    Button {
                        showInformations.toggle()
                    } label: {
                        Label("Informations", systemImage: "info.circle")
                    }
                    .sheet(isPresented: $showInformations) {
                        InformationsView()
                    }
                }
            }
            .navigationTitle("INSA Radar")
        }
        .onAppear {
            refresh()
            date = Date()
        }
    }
    
    func refresh() {
        Task {
            withAnimation { buffering = true }
            salles = try await getSalles(from: "https://apps-int.insa-strasbourg.fr/ade/export.php?projectId=30&resources=5982,5987,5985,5988,5989,4360,5992,5990")
            refreshDate()
            withAnimation { buffering = false }
        }
    }
    
    func refreshDate() {
        availableSalles = salles.filter({$0.isAvailable(on: date)})
        notAvailableSalles = salles.filter({!$0.isAvailable(on: date)})
    }
}

struct AvailableSalleView: View {
    @State var date: Date
    @State var salle: Salle
    
    var body: some View {
        let nextUnavailableTime: String? = salle.nextUnavailableTime(after: date)?.formatted(date: .omitted, time: .standard)
        if let nextUnavailableTime = nextUnavailableTime {
            Text(salle.nom + " - disponible jusqu'à " +  nextUnavailableTime)
        } else {
            Text(salle.nom + " - disponible")
        }
    }
}

func testDate() -> Date? {
    let calendar = Calendar.current
    var dateComponents = DateComponents()
    dateComponents.year = 2024 // or any year you want
    dateComponents.month = 1 // January
    dateComponents.day = 30 // 29th
    dateComponents.hour = 11 // 9 AM
    dateComponents.minute = 0

    if let date = calendar.date(from: dateComponents) {
        return date
    }
    return nil
}

#Preview {
    ContentView()
}
