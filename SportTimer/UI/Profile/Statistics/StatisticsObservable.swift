//
//  StatisticsObservable.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import CoreData

class StatisticsObservable: TrainingObservable {
    
    @Published var workoutTypes: [String: Int] = [:]
    
    func fetchTypeStats(context: NSManagedObjectContext) {
        workoutTypes.removeAll()
            
        TrainingModesEnum.allCases.forEach { modeName in
            workoutTypes[modeName.rawValue] = 0
        }
        
        nowLoading = true
        
        Task {
            await updateWorkoutStats(context: context)
        }
    }
    
    @MainActor
    private func updateWorkoutStats(context: NSManagedObjectContext) async {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            
            if let result = result as? [NSManagedObject] {
                for item in result {
                    if let workout = item as? Workout, let type = workout.type, let previousCount = workoutTypes[type] {
                        workoutTypes[type] = previousCount + 1
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        nowLoading = false
    }
}
