//
//  SettingsObservable.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import CoreData

class SettingsObservable: ObservableObject {
    
    @Published var shouldPresentSoundSelection = false
    @Published var timerSoundList: [ActionSheet.Button] = []
    
    func setupTimerSoundList(context: NSManagedObjectContext) {
        timerSoundList.removeAll()
        
        SoundNamesEnum.allCases.forEach { soundName in
            if let index = SoundNamesEnum.allCases.firstIndex(of: soundName) {
                timerSoundList.append(.default(Text(soundName.rawValue), action: {
                    self.shouldPresentSoundSelection = false
                    
                    Task {
                        await self.updateTimerSoundID(context: context, soundID: SystemSoundsEnum.allCases[index].rawValue)
                    }
                }))
            }
        }
    }
    
    func clearAppCache(context: NSManagedObjectContext) {
        Task {
            await clearTrainingHistory(context: context)
        }
    }
    
    private func updateTimerSoundID(context: NSManagedObjectContext, soundID: Int) async {
        await clearPreviousSettings(context: context)
        
        if let entity = NSEntityDescription.entity(forEntityName: "AppSettings", in: context) {
            let appSettings = NSManagedObject(entity: entity, insertInto: context)
            
            appSettings.setValue(soundID, forKey: "timerSoundID")
            
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func clearPreviousSettings(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppSettings")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject] {
                for obsoleteObject in result {
                    context.delete(obsoleteObject)
                }
                
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func clearTrainingHistory(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject] {
                for obsoleteObject in result {
                    context.delete(obsoleteObject)
                }
                
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
