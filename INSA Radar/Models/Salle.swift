//
//  Salle.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation
import SwiftData

@Model
final class Salle {
    var nom: String = ""
    var requete: Requete?
    var evenements: [Evenement]? = []
    
    init(nom: String) {
        self.nom = nom
    }
    
    func isFreeAtDate(date: Date) -> Bool {
        if let evenements = evenements {
            return evenements.allSatisfy { !$0.isHappeningAtDate(date: date) }
        }
        return false
    }
}
