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

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Voir les salles disponibles le", selection: $date)
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

struct AvailableSalleView: View {
    @Binding var date: Date
    @State var salle: Salle
    
    var body: some View {
        if let nextUnavailableTime: Date = salle.nextUnavailableTime(after: date) {
            if isSameDay(date1: date, date2: nextUnavailableTime) {
                let nextUnavailableDateString = nextUnavailableTime.formatted(date: .omitted, time: .shortened)
                Text(salle.nom + " - Disponible jusqu'à " + nextUnavailableDateString)
            } else {
                Text(salle.nom + " - Disponible toute la journée")
            }
        } else {
            Text(salle.nom + " - Disponible")
        }
    }
}

struct UnavailableSalleView: View {
    @Binding var date: Date
    @State var salle: Salle
    
    var body: some View {
        if let nextAvailableDate: Date = salle.nextAvailableTime(after: date) {
            if isSameDay(date1: date, date2: nextAvailableDate) {
                let nextAvailableDateString = nextAvailableDate.formatted(date: .omitted, time: .shortened)
                Text(salle.nom + " - Indisponible jusqu'à " + nextAvailableDateString)
            } else {
                Text(salle.nom + " - Indisponible toute la journée")
            }
        } else {
            Text(salle.nom + " - Indisponible")
        }
    }
}

func isSameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    let components1 = calendar.dateComponents([.month, .day], from: date1)
    let components2 = calendar.dateComponents([.month, .day], from: date2)

    return components1.month == components2.month &&
           components1.day == components2.day
}

#Preview {
    ContentView(updateOnOpen: false)
}
