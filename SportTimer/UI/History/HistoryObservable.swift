//
//  HistoryObservable.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import CoreData

class HistoryObservable: TrainingObservable {
    
    @Published var searchFilter = ""
    @Published var workoutHistoryGroups: [String: [Workout]] = [:]
    
    @Published var groupInfoOffsets: [[CGFloat]] = []
    
    func fetchLatestTrainingItems(context: NSManagedObjectContext) {
        nowLoading = true
        
        Task {
            await updateWorkoutList(context: context)
        }
    }
    
    func removeTraining(uuid: UUID, context: NSManagedObjectContext) {
        Task {
            await removeTrainingFromHistory(uuid: uuid, context: context)
            await updateWorkoutList(context: context)
        }
    }
    
    func clearOffsetsExceptCurrent(groupIndex: Int, index: Int) {
        for i in 0..<groupInfoOffsets.count {
            for j in 0..<groupInfoOffsets[i].count {
                if !(i == groupIndex && j == index) {
                    groupInfoOffsets[i][j] = 0
                }
            }
        }
    }
    
    @MainActor
    private func updateWorkoutList(context: NSManagedObjectContext) async {
        groupInfoOffsets.removeAll()
        workoutHistoryGroups.removeAll()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject] {
                totalNumberOfWorkouts = result.count
                
                for item in result {
                    if let workout = item as? Workout, let workoutDate = workout.date, (searchFilter.count > 0 && workout.type?.contains(searchFilter) == true || searchFilter.count == 0) {
                        
                        var currentGroup: [Workout] = workoutHistoryGroups[formatter.string(from: workoutDate)] ?? []
                        currentGroup.append(workout)
                        
                        workoutHistoryGroups[formatter.string(from: workoutDate)] = currentGroup
                    }
                }
                
                for i in 0..<workoutHistoryGroups.keys.count {
                    groupInfoOffsets.append([])
                    
                    let key = Array(workoutHistoryGroups.keys)[i]
                    if let workoutGroup = workoutHistoryGroups[key] {
                        for _ in 0..<workoutGroup.count {
                            groupInfoOffsets[i].append(0)
                        }
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        nowLoading = false
    }
}
