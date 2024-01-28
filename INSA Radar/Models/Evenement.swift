//
//  Evenement.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 27/01/2024.
//

import Foundation
import iCalendarParser

final class Evenement {
    var startDate: Date?
    var endDate: Date?
    
    init(icEvent: ICEvent) {
        self.startDate = icEvent.dtStart?.date
        self.endDate = icEvent.dtEnd?.date
    }
    
    func isHappening(on givenDate: Date) -> Bool {
        guard let startDate = startDate, let endDate = endDate else {
            return false
        }
        return (startDate...endDate).contains(givenDate)
    }
    
    func isHappening(between startDate: Date, and endDate: Date) -> Bool {
        guard let eventStartDate = self.startDate, let eventEndDate = self.endDate else {
            return false
        }
        return (eventStartDate...eventEndDate).overlaps(startDate...endDate)
    }
}
