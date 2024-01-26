//
//  Evenement.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation
import SwiftData

@Model
final class Evenement {
    var startDate: Date?
    var endDate: Date?
    var salle: Salle?
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func isHappeningAtDate(date: Date) -> Bool {
        if let startDate = startDate {
            if let endDate = endDate {
                return date >= startDate && date <= endDate
            }
        }
        return false
    }
}
