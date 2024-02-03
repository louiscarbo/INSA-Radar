//
//  InformationsView.swift
//  INSA Radar
//
//  Created by Louis Carbo Estaque on 28/01/2024.
//

import SwiftUI

struct InformationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Comment fonctionne INSA Radar ?")
                        .font(.title2)
                        .bold()
                    Text("**INSA Radar récupère les informations sur les salles disponibles depuis l'emploi du temps** de l'INSA, à partir d'un lien de synchronisation similaire à celui que vous utilisez pour synchroniser votre emploi du temps à votre calendrier.")
                        .padding(.bottom)
                    Text("À l'ouverture d'INSA Radar, l'application doit télécharger et traiter les événements du calendrier de l'INSA. Cela explique les quelques secondes d'attente au début. Je travaille actuellement à réduire le délai d'ouverture de l'application.")
                        .padding(.bottom)
                    
                    Text("Comment signaler un bug, envoyer une suggestion, une remarque ?")
                        .font(.title2)
                        .bold()
                    Text("Si vous souhaitez signaler un bug, envoyer une suggestion, une remarque, proposer d'exclure une salle qui n'est pas pertinente pour l'application... N'hésitez pas à me contacteer, Louis CARBO ESTAQUE (GE2), par exemple par mail :")
                    Button {
                        let mailTo = String(localized: "mailto:louis.carbo_estaque@insa-strasbourg.fr?subject=INSA Radar").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let mailToUrl = URL(string: mailTo!)!
                        if UIApplication.shared.canOpenURL(mailToUrl) {
                            UIApplication.shared.open(mailToUrl, options: [:])
                        }
                    } label: {
                        Label("louis.carbo_estaque@insa-strasbourg.fr", systemImage: "envelope.fill")
                            .tint(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                    
                    Text("Une version Android est-elle prévue ?")
                        .font(.title2)
                        .bold()
                    Text("Pour l'instant, je ne prévois pas de créer une version Android. Android et iOS étant deux plateformes différentes, il faudrait recoder entièrement une application pour Android, ce dont je n'ai pas les capacités pour l'instant.")
                        .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Informations")
            .toolbar {
                ToolbarItem {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    Text("Hi")
        .sheet(isPresented: .constant(true), content: {
            InformationsView()
        })
}
