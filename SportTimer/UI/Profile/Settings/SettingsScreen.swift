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
                ActionSheet(title: Text(NSLocalizedString("TimerSound", comment: "")), message: nil, buttons: settingsObservable.timerSoundList)
            }.task {
                settingsObservable.setupTimerSoundList(context: viewContext)
            }
    }
    
    @ViewBuilder
    var timerSound: some View {
        VStack {
            Text(NSLocalizedString("TimerSound", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            SolidButton(text: NSLocalizedString("SetTimerSound", comment: "")) {
                settingsObservable.shouldPresentSoundSelection = true
            }
        }
    }
    
    @ViewBuilder
    var removeData: some View {
        VStack {
            Text(NSLocalizedString("AppCache", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            SolidButton(text: NSLocalizedString("ClearCache", comment: "")) {
                showConfirmationDialog {
                    settingsObservable.clearAppCache(context: viewContext)
                }
            }
        }
    }
    
    @ViewBuilder
    var about: some View {
        VStack {
            Text(NSLocalizedString("About", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                StatsLabel(title: NSLocalizedString("AppVersion", comment: ""), value: appVersion)
            }
        }
    }
    
    private func showConfirmationDialog(confirmationHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: NSLocalizedString("ConfirmAction", comment: ""), message: NSLocalizedString("ClearConfirmation", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) {_ in
            alert.dismiss(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) {_ in
            alert.dismiss(animated: true)
            
            confirmationHandler()
        })
        
        alert.presentAlert()
    }
}
