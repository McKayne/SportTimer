//
//  TrainingObservable.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import UserNotifications
import AVFoundation
import CoreData

class TrainingObservable: ObservableObject {
    
    private let defaultSoundID: UInt32 = 1020
    
    @Published var nowLoading = false
    
    @Published var isTrainingStarted = false
    @Published var isTrainingPaused = false
    
    @Published var type = "Other"
    @Published var descriptionText = NSLocalizedString("TrainingPlaceholder", comment: "")
    
    @Published var currentTimerSeconds = 0
    @Published var formattedTimerString = ""
    
    @Published var infoOffsets: [CGFloat] = []
    @Published var workoutList: [Workout] = []
    
    @Published var totalNumberOfWorkouts = 0
    
    private var timer: Timer?
    
    func handleTrainingButtonAction(context: NSManagedObjectContext) {
        Task {
            await fetchAndPlayTimerSound(context: context)
        }
        
        if isTrainingPaused {
            resumeTraining(context: context)
        } else if isTrainingStarted {
            pauseTraining(context: context)
        } else {
            startTraining(context: context)
        }
    }
    
    func startTraining(context: NSManagedObjectContext) {
        isTrainingStarted = true
        
        showTrainingNotification()
        
        Task {
            await startTimerEntity(context: context)
        }
    }
    
    func pauseTraining(context: NSManagedObjectContext) {
        isTrainingPaused = true
        
        Task {
            await pauseLastTraining(context: context)
        }
    }
    
    func resumeTraining(context: NSManagedObjectContext) {
        isTrainingPaused = false
        
        Task {
            await resumeLastTraining(context: context)
        }
    }
    
    func finishTraining(context: NSManagedObjectContext) {
        isTrainingStarted = false
        isTrainingPaused = false
        
        showTrainingNotification()
        
        Task {
            await fetchAndPlayTimerSound(context: context)
            await appendWorkout(context: context)
            await clearLastTraining(context: context)
            await updateWorkoutList(shouldLimit: true, context: context, searchFilter: "")
        }
    }
    
    private func showTrainingNotification() {
        let content = UNMutableNotificationContent()
        content.title = isTrainingStarted ? "Get ready!" : "Well done!"
        content.subtitle = isTrainingStarted ? "Training started!" : "Training finished!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func fetchLatestTrainingItems(shouldLimit: Bool, context: NSManagedObjectContext, searchFilter: String = "") {
        nowLoading = true
        
        Task {
            await updateWorkoutList(shouldLimit: shouldLimit, context: context, searchFilter: searchFilter)
        }
    }
    
    func fetchTimerState(context: NSManagedObjectContext) {
        nowLoading = true
        
        Task {
            await updateTrainingState(context: context)
        }
    }
    
    func clearOffsetsExceptCurrent(index: Int) {
        for i in 0..<infoOffsets.count {
            if i != index {
                infoOffsets[i] = 0
            }
        }
    }
    
    private func formatTimerString() {
        let seconds = currentTimerSeconds % 60
        let minutes = currentTimerSeconds / 60 % 60
        let hours = currentTimerSeconds / 3600
        
        if hours > 0 {
            formattedTimerString = String(format: "%02d", hours) + ":" + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        } else {
            formattedTimerString = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        }
    }
    
    func startTimer(context: NSManagedObjectContext) {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task {
                    await self.updateTrainingState(context: context)
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func removeTraining(shouldLimit: Bool, uuid: UUID, context: NSManagedObjectContext) {
        Task {
            await removeTrainingFromHistory(uuid: uuid, context: context)
            await updateWorkoutList(shouldLimit: shouldLimit, context: context, searchFilter: "")
        }
    }
    
    // MARK: - Core Data methods
    
    @MainActor
    private func updateWorkoutList(shouldLimit: Bool, context: NSManagedObjectContext, searchFilter: String) async {
        infoOffsets.removeAll()
        workoutList.removeAll()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject] {
                totalNumberOfWorkouts = result.count
                
                for item in result {
                    if let workout = item as? Workout, (searchFilter.count > 0 && workout.type?.contains(searchFilter) == true || searchFilter.count == 0) {
                        workoutList.append(workout)
                        infoOffsets.append(0)
                    }
                }
                
                workoutList.reverse()
                infoOffsets.reverse()
                
                if shouldLimit, infoOffsets.count > 3 {
                    workoutList = Array(workoutList.prefix(3))
                    infoOffsets = Array(infoOffsets.prefix(3))
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        nowLoading = false
    }
    
    private func fetchAndPlayTimerSound(context: NSManagedObjectContext) async {
        var soundID = defaultSoundID
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "AppSettings")
        request.returnsObjectsAsFaults = false
            
        do {
            let result = try context.fetch(request)
                
            if let result = result as? [NSManagedObject], let appSettings = result.first as? AppSettings {
                soundID = UInt32(appSettings.timerSoundID)
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        AudioServicesPlaySystemSound(soundID)
    }
    
    private func startTimerEntity(context: NSManagedObjectContext) async {
        await clearLastTraining(context: context)
        
        if let entity = NSEntityDescription.entity(forEntityName: "LastTraining", in: context) {
            let lastTraining = NSManagedObject(entity: entity, insertInto: context)
            
            lastTraining.setValue(type, forKey: "type")
            lastTraining.setValue(Date().timeIntervalSince1970, forKey: "timerStartedAt")
            lastTraining.setValue(0, forKey: "timerPausedAt")
            lastTraining.setValue(0, forKey: "numberOfSecondsCounted")
            
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func appendWorkout(context: NSManagedObjectContext) async {
        if let entity = NSEntityDescription.entity(forEntityName: "Workout", in: context) {
            let workout = NSManagedObject(entity: entity, insertInto: context)
            
            workout.setValue(UUID(), forKey: "id")
            workout.setValue(type, forKey: "type")
            workout.setValue(currentTimerSeconds, forKey: "duration")
            workout.setValue(Date(), forKey: "date")
            workout.setValue(descriptionText, forKey: "notes")
            
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    private func clearLastTraining(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LastTraining")
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
        
        currentTimerSeconds = 0
        formatTimerString()
    }
    
    @MainActor
    private func removeTrainingFromHistory(uuid: UUID, context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject] {
                for item in result {
                    if let workout = item as? Workout, workout.id == uuid {
                        context.delete(item)
                    }
                }
                
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func pauseLastTraining(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LastTraining")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject], let lastTraining = result.first as? LastTraining {
                lastTraining.setValue(lastTraining.numberOfSecondsCounted + (Int64(Date().timeIntervalSince1970) - lastTraining.timerStartedAt),
                                      forKey: "numberOfSecondsCounted")
                lastTraining.setValue(Date().timeIntervalSince1970, forKey: "timerPausedAt")
                
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func resumeLastTraining(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LastTraining")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject], let lastTraining = result.first as? LastTraining {
                lastTraining.setValue(Date().timeIntervalSince1970, forKey: "timerStartedAt")
                lastTraining.setValue(0, forKey: "timerPausedAt")
                
                try context.save()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    private func updateTrainingState(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LastTraining")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject], let lastTraining = result.first as? LastTraining {
                isTrainingStarted = true
                type = lastTraining.type ?? ""
                
                isTrainingPaused = lastTraining.timerPausedAt != 0
                
                if isTrainingPaused {
                    currentTimerSeconds = Int(lastTraining.numberOfSecondsCounted)
                } else {
                    currentTimerSeconds = Int(Date().timeIntervalSince1970) - Int(lastTraining.timerStartedAt) + Int(lastTraining.numberOfSecondsCounted)
                }
            } else {
                isTrainingStarted = false
                isTrainingPaused = false
                currentTimerSeconds = 0
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        formatTimerString()
        nowLoading = false
    }
}
