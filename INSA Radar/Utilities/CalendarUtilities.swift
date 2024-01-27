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

func getNomsSallesFromICalendar(calendar: ICalendar) async throws -> [String] {
    var nomsSalles: [String] = []
    
    for event in calendar.events {
        for nomSalle in getNomsSallesFromICEvent(iCalEvent: event) {
            nomsSalles.append(nomSalle)
        }
    }
    
    return Array(Set(nomsSalles)).sorted(by: {$0 <= $1})
}

func getSallesAndEvents(from urlString: String) async throws -> [Salle] {
    
    if let calendar = try await getCalendarFromURL(from: urlString) {
        let nomSalles = try await getNomsSallesFromICalendar(calendar: calendar)
        
        var salles: [Salle] = []
        
        for nomSalle in nomSalles {
            let newSalle = Salle(nom: nomSalle)
            salles.append(newSalle)
            
            for event in calendar.events {
                for nomSalleEvent in getNomsSallesFromICEvent(iCalEvent: event) {
                    if nomSalleEvent == nomSalle {
                        let newEvenement = Evenement()
                        newEvenement.startDate = event.dtStart?.date
                        newEvenement.endDate = event.dtEnd?.date
                        
                        newSalle.evenements.append(newEvenement)
                    }
                }
            }
        }
        return salles

    }
    
    return []
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
