//
//  NotasAppApp.swift
//  NotasApp
//
//  Created by IOS SENAC on 9/4/21.
//

import SwiftUI

@main
struct NotasAppApp: App {
    let persistenceController = PersistenceController.banco
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
