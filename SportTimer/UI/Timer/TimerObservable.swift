//
//  TimerObservable.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import UserNotifications
import AVFoundation
import CoreData

class TimerObservable: TrainingObservable {
    
    @Published var shouldPresentModeSelection = false
    @Published var trainingModesList: [ActionSheet.Button] = []
    
    func setupTrainingModesList(context: NSManagedObjectContext) {
        trainingModesList.removeAll()
        
        TrainingModesEnum.allCases.forEach { modeName in
            trainingModesList.append(.default(Text(modeName.rawValue), action: { [weak self] in
                self?.shouldPresentModeSelection = false
                    
                self?.type = modeName.rawValue
                    
                self?.handleTrainingButtonAction(context: context)
            }))
        }
    }
}
