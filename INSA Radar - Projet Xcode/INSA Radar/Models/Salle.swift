//
//  Salle.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation
import iCalendarParser

final class Salle: Observable {
    var identifier = UUID()
    var nom: String = ""
    var evenements: [Evenement] = []
    
    init(nom: String) {
        self.nom = nom
    }
    
    func isAvailable(on givenDate: Date) -> Bool {
        for evenement in evenements {
            if evenement.isHappening(on: givenDate) {
                return false
            }
        }
        return true
    }
    
    func isAvailable(between startDate: Date, and endDate: Date) -> Bool {
        for evenement in evenements {
            if evenement.isHappening(between: startDate, and: endDate) {
                return false
            }
        }
        return true
    }
    
    func nextUnavailableTime(after date: Date) -> Date? {
        let sortedEvents = evenements.sorted { $0.startDate ?? Date.distantPast < $1.startDate ?? Date.distantPast }
        for evenement in sortedEvents {
            if let eventStartDate = evenement.startDate, eventStartDate > date {
                return eventStartDate
            }
        }
        return nil
    }
    
    func nextAvailableTime(after date: Date) -> Date? {
        let sortedEvents = evenements.sorted { $0.endDate ?? Date.distantPast < $1.endDate ?? Date.distantPast }
        for evenement in sortedEvents {
            if let eventEndDate = evenement.endDate, eventEndDate > date {
                return eventEndDate
            }
        }
        return nil
    }
}
