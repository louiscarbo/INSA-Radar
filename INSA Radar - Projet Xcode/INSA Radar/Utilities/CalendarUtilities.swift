//
//  CalendarUtilities.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation
import iCalendarParser

private func getCalendarFromURL(from urlString: String) async throws -> ICalendar? {
    if let url = URL(string: urlString) {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let icsString = String(data: data, encoding: .utf8) else {
            fatalError()
        }
        
        let parser = ICParser()
        return parser.calendar(from: icsString)
    }
    return nil
}

private func getNomsSallesFromICEvent(iCalEvent: ICEvent) -> [String] {
    var nomsSalles: [String] = []
    
    if let location = iCalEvent.location {
        nomsSalles = getSallesStringsFromLocation(in: location)
        
        return nomsSalles
    }
    return []
}

private func getSallesStringsFromLocation(in sourceString: String) -> [String] {
    let regexPattern = "[A-F][0-4]\\.[0-2][0-9]"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let range = NSRange(sourceString.startIndex..<sourceString.endIndex, in: sourceString)

        let matches = regex.matches(in: sourceString, options: [], range: range)
        return matches.map { match in
            let range = Range(match.range, in: sourceString)!
            return String(sourceString[range])
        }
    } catch {
        print("Error creating regex: \(error)")
        return []
    }
}

func getSalles(from urlString: String) async throws -> [Salle] {
    let sallesExclues = [
        "C0.04",
        "C1.14",
        "C2.18",
        "C2.27",
        "D2.02"
    ]
    
    var salles: [Salle] = []
    
    // Récupère le calendrier depuis l'URL fourni
    if let calendar = try await getCalendarFromURL(from: urlString) {
        var dictionary: [String:[Evenement]] = [:]
        
        for event in calendar.events {
            let nomsSalles = getNomsSallesFromICEvent(iCalEvent: event)
            
            // Ajoute l'événement en question à chaque salle
            for nomSalle in nomsSalles {
                var newEvents: [Evenement]
                if let currentEvents: [Evenement] = dictionary[nomSalle] {
                    newEvents = currentEvents
                                        
                    newEvents.append(Evenement(icEvent: event))
                } else {
                    newEvents = [Evenement(icEvent: event)]
                }
                dictionary.updateValue(newEvents, forKey: nomSalle)
            }
        }
        
        for nomSalle in dictionary.keys {
            if !sallesExclues.contains(nomSalle) {
                let newSalle = Salle(nom: nomSalle)
                newSalle.evenements = dictionary[nomSalle] ?? []
                salles.append(newSalle)
            }
        }
    }
    
    return salles.sorted(by: {$0.nom <= $1.nom})
}
