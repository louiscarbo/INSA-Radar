//
//  GeneralUtilities.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation

func replaceBackslashN(stringWithBacklashN: String) -> String {
    return stringWithBacklashN.replacingOccurrences(of: "\\n", with: "\n").trimmingCharacters(in: .newlines)
}

func isSameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    let components1 = calendar.dateComponents([.month, .day], from: date1)
    let components2 = calendar.dateComponents([.month, .day], from: date2)

    return components1.month == components2.month &&
           components1.day == components2.day
}
