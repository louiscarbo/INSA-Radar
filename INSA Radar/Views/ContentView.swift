//
//  ContentView.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import SwiftUI
import SwiftData
import iCalendarParser

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Requete]
    
    @State private var iCalendar: ICalendar?
    @State private var buffering = false

    var body: some View {
        VStack {
            Button("Fetch Data") {
                Task {
                    buffering = true
                    iCalendar = await getCalendarFromURL(urlString: "https://apps-int.insa-strasbourg.fr/ade/export.php?projectId=30&resources=5987")
                    buffering = false
                }
            }
            if buffering {
                ProgressView()
                Spacer()
            } else {
                List {
                    if let iCalendar = iCalendar {
                        ForEach(iCalendar.events, id:\.uid) { event in
                            if let location = event.location {
                                Text(location)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Requete.self)
}
