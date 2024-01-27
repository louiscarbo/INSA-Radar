//
//  INSA_RadarApp.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import SwiftUI

@main
struct INSA_RadarApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Requete.self,
//            Salle.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
//        .modelContainer(sharedModelContainer)
    }
}
