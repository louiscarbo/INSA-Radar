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
    ContentView()
}
