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
    var requete: Requete?
    var evenements: [Evenement] = []
    
    init(requete: Requete, nom: String) {
        self.requete = requete
        self.nom = nom
    }
    
    init(nom: String) {
        self.nom = nom
    }
}
