//
//  CalendarUtilities.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation
import iCalendarParser

private func fetchICSString(from url: URL) async throws -> String {
    let (data, _) = try await URLSession.shared.data(from: url)
    
    guard let icsString = String(data: data, encoding: .utf8) else {
        throw NSError(domain: "com.yourapp.error", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string."])
    }

    return icsString
}

private func getCalendarFromICSString(icsString: String) -> ICalendar? {
    let parser = ICParser()
    return parser.calendar(from: icsString)
}

func getCalendarFromURL(urlString: String) async -> ICalendar? {
    let url = URL(string: urlString)!
    if let rawICS = try? await fetchICSString(from: url) {
        return getCalendarFromICSString(icsString: rawICS)
    }
    return nil
}
