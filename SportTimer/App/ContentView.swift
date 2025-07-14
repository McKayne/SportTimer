//
//  ContentView.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        TabView {
            homeTab
                .tabItem {
                    Image(systemName: "house")
                    Text(NSLocalizedString("HomeTab", comment: ""))
                }
            
            timerTab
                .tabItem {
                    Image(systemName: "timer")
                    Text(NSLocalizedString("TimerTab", comment: ""))
                }
            
            historyTab
                .tabItem {
                    Image(systemName: "book")
                    Text(NSLocalizedString("HistoryTab", comment: ""))
                }
            
            profileTab
                .tabItem {
                    Image(systemName: "person")
                    Text(NSLocalizedString("ProfileTab", comment: ""))
                }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
    }
    
    @ViewBuilder
    var homeTab: some View {
        NavigationView {
            HomeScreen()
                .navigationTitle(NSLocalizedString("HomeTitle", comment: ""))
        }
    }
    
    @ViewBuilder
    var timerTab: some View {
        NavigationView {
            TimerScreen()
                .navigationTitle(NSLocalizedString("TimerTitle", comment: ""))
        }
    }
    
    @ViewBuilder
    var historyTab: some View {
        NavigationView {
            HistoryScreen()
                .navigationTitle(NSLocalizedString("HistoryTitle", comment: ""))
        }
    }
    
    @ViewBuilder
    var profileTab: some View {
        NavigationView {
            ProfileScreen()
                .navigationTitle(NSLocalizedString("ProfileTitle", comment: ""))
        }
    }
}

func showConfirmationDialog(confirmationHandler: @escaping () -> Void) {
    let alert = UIAlertController(title: NSLocalizedString("ConfirmAction", comment: ""), message: NSLocalizedString("FinishConfirmation", comment: ""), preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {_ in
        alert.dismiss(animated: true)
    })
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Finish", comment: ""), style: .default) {_ in
        alert.dismiss(animated: true)
        
        confirmationHandler()
    })
    
    alert.presentAlert()
}

func showItemDeletionDialog(confirmationHandler: @escaping () -> Void) {
    let alert = UIAlertController(title: NSLocalizedString("ConfirmAction", comment: ""), message: NSLocalizedString("DeleteConfirmation", comment: ""), preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {_ in
        alert.dismiss(animated: true)
    })
    
    alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) {_ in
        alert.dismiss(animated: true)
        
        confirmationHandler()
    })
    
    alert.presentAlert()
}
