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
