//
//  ContentView.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import SwiftUI
import iCalendarParser

struct ContentView: View {
    var updateOnOpen = true
    
    @State private var salles: [Salle] = []
    private var availableSalles: [Salle] {
        let salles = salles.filter({$0.isAvailable(on: date)})
        return filterBatimentEtage(salles: salles)
    }
    
    private var notAvailableSalles: [Salle] {
        let salles = salles.filter({!$0.isAvailable(on: date)})
        return filterBatimentEtage(salles: salles)
    }
    
    @State private var date: Date = Date()
    @State private var showInformations = false
    @State private var showSalleSheet = false
    
    @State private var buffering = false
    
    @State private var batimentsToShow: [String:Bool] = [
        "C": true,
        "E": true,
        "F": true
    ]
    
    @State private var etagesToShow: [Int:Bool] = [
        0: true,
        1: true,
        2: true,
        3: true,
        4: true
    ]

    // MARK: View
    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Voir les salles disponibles le", selection: $date, in: Date().addingTimeInterval(-7*24*3600.0)...Date().addingTimeInterval(7*24*3600) )
                    Button("Maintenant") {
                        date = Date()
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
                                AvailableSalleView(date: $date, salle: salle)
                            }
                        }
                    }
                    if notAvailableSalles.count > 0 {
                        Section("Salles non disponibles") {
                            ForEach(notAvailableSalles, id: \.identifier) { salle in
                                UnavailableSalleView(date:  $date, salle: salle)
                            }
                        }
                    }
                    if availableSalles.count == 0 && notAvailableSalles.count == 0 {
                        if salles.count == 0 {
                            Text("Rafraîchissez l'application à l'aide du bouton en haut de l'écran.")
                        } else {
                            ContentUnavailableView(
                                "Aucune salle trouvée",
                                systemImage: "magnifyingglass",
                                description: Text("Modifiez vos filtres pour trouver une salle libre."))
                        }
                    }
                }
            }
            
            // MARK: Toolbar
            .toolbarRole(.editor)
            .toolbar {
                ToolbarItem {
                    Button {
                        refresh()
                    } label: {
                        Label("Rafraîchir", systemImage: "arrow.clockwise")
                    }
                    .disabled(buffering)
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
                ToolbarItem {
                    Menu("Filtrer", systemImage: "slider.vertical.3") {
                        Text("Filtrer par")
                        Menu("Bâtiment") {
                            ForEach(["C", "E", "F"], id: \.self) { batiment in
                                ToggleBatiment(batiment: batiment, batimentsToShow: $batimentsToShow)
                            }
                        }
                        Menu("Étage") {
                            ForEach(0...4, id: \.self) { etage in
                                ToggleEtage(etage: etage, etagesToShow: $etagesToShow)
                            }
                        }
                    }
                }
            }
            .navigationTitle("INSA Radar")
        }
        .onAppear {
            if updateOnOpen {
                refresh()
                date = Date()
            }
        }
    }
    
    func refresh() {
        Task {
            withAnimation { buffering = true }
            salles = try await getSalles(from: "https://apps-int.insa-strasbourg.fr/ade/export.php?projectId=30&resources=5982,5987,5985,5988,5989,4360,5992,5990")
            withAnimation { buffering = false }
        }
    }
    
    func filterBatimentEtage(salles: [Salle]) -> [Salle] {
        let salles = salles.filter({ salle in
            guard let batiment = salle.nom.first.map(String.init) else { return false }
            return batimentsToShow[batiment] ?? false
        })
        return salles.filter({ salle in
            let etageString = String(salle.nom[salle.nom.index(salle.nom.startIndex, offsetBy: 1)])
            guard let etage = Int(etageString) else { return false }
            return etagesToShow[etage] ?? false
        })
    }
}

struct ToggleBatiment: View {
    @State var batiment: String
    @Binding var batimentsToShow: [String:Bool]
    
    var body: some View {
        Toggle(batiment, isOn:  Binding(
            get: { batimentsToShow[batiment] ?? false },
            set: { batimentsToShow[batiment] = $0 }
        ))
    }
}

struct ToggleEtage: View {
    @State var etage: Int
    @Binding var etagesToShow: [Int:Bool]
    
    var body: some View {
        Toggle(String(etage), isOn:  Binding(
            get: { etagesToShow[etage] ?? false },
            set: { etagesToShow[etage] = $0 }
        ))
    }
}

// MARK: Available Salles
struct AvailableSalleView: View {
    @Binding var date: Date
    @State var salle: Salle
    
    @State private var displayText = ""
    @State private var showSalleSheet = false
    
    var body: some View {
        
        Text(displayText)
            .sheet(isPresented: $showSalleSheet) {
                SalleView(salle: salle.nom)
            }
            .onTapGesture(count: 1, perform: {
                showSalleSheet.toggle()
            })
            .onAppear {
                displayText = getAvailableSalleText(salle: salle, date: date)
            }
    }
}

private func getAvailableSalleText(salle: Salle, date: Date) -> String {
    guard let nextUnavailableTime = salle.nextAvailableTime(after: date) else {
        return salle.nom + " - Disponible"
    }
    
    if isSameDay(date1: date, date2: nextUnavailableTime) {
        let nextUnavailableDateString = nextUnavailableTime.formatted(date: .omitted, time: .shortened)
        return salle.nom + " - Disponible jusqu'à " + nextUnavailableDateString
    } else {
        return salle.nom + " - Disponible toute la journée"
    }
}

// MARK: Unavailable Salles
struct UnavailableSalleView: View {
    @Binding var date: Date
    @State var salle: Salle
    
    @State private var displayText = ""
    @State private var showSalleSheet = false
    
    var body: some View {
        Text(displayText)
            .sheet(isPresented: $showSalleSheet) {
                SalleView(salle: salle.nom)
            }
            .onTapGesture(count: 1, perform: {
                showSalleSheet.toggle()
            })
            .onAppear {
                displayText = getUnavailableSalleText(salle: salle, date: date)
            }
    }
}

private func getUnavailableSalleText(salle: Salle, date: Date) -> String {
    guard let nextAvailableTime = salle.nextAvailableTime(after: date) else {
        return salle.nom + " - Indisponible"
    }
    
    if isSameDay(date1: date, date2: nextAvailableTime) {
        let nextAvailableDateString = nextAvailableTime.formatted(date: .omitted, time: .shortened)
        return salle.nom + " - Indisponible jusqu'à " + nextAvailableDateString
    } else {
        return salle.nom + " - Indisponible toute la journée"
    }
}

#Preview {
    ContentView(updateOnOpen: false)
}
