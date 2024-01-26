//
//  Requete.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 26/01/2024.
//

import Foundation
import SwiftData

@Model
final class Requete {
    var date: Date = Date()
    var salles: [Salle]? = []
    
    init() {}
}
