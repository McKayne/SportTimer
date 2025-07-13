//
//  SettingsScreen.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct SettingsScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var settingsObservable = SettingsObservable()
    
    var body: some View {
        ScrollView {
            VStack {
                
                timerSound
        
                removeData
                
                about
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .actionSheet(isPresented: $settingsObservable.shouldPresentSoundSelection) {
                ActionSheet(title: Text("Timer sound"), message: nil, buttons: settingsObservable.timerSoundList)
            }.task {
                settingsObservable.setupTimerSoundList(context: viewContext)
            }
    }
    
    @ViewBuilder
    var timerSound: some View {
        VStack {
            Text("Timer sound")
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            SolidButton(text: "Set timer sound") {
                settingsObservable.shouldPresentSoundSelection = true
            }
        }
    }
    
    @ViewBuilder
    var removeData: some View {
        VStack {
            Text("App cache")
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            SolidButton(text: "Remove all data") {
                showConfirmationDialog {
                    
                }
            }
        }
    }
    
    @ViewBuilder
    var about: some View {
        VStack {
            Text("About the app")
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            StatsLabel(title: "App version:", value: "1.0 (1)")
        }
    }
    
    private func showConfirmationDialog(confirmationHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Confirm this action", message: "Are you sure you want to delete all app data? This cannot be undone", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in
            alert.dismiss(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) {_ in
            alert.dismiss(animated: true)
            
            confirmationHandler()
        })
        
        alert.presentAlert()
    }
}
