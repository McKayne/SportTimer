//
//  HomeScreen.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct HomeScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var homeObservable = HomeObservable()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    
                    shortStats
                    
                    TrainingButton(isTrainingStarted: $homeObservable.isTrainingStarted,
                                   isTrainingPaused: $homeObservable.isTrainingPaused,
                                   finishTrainingCompletion: {
                        showConfirmationDialog {
                            homeObservable.finishTraining(context: viewContext)
                        }
                    }).onTapGesture {
                        homeObservable.handleTrainingButtonAction(context: viewContext)
                    }
                    
                    lastTrainingInfo
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if homeObservable.nowLoading {
                NowLoading()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                homeObservable.fetchLatestTrainingItems(shouldLimit: true, context: viewContext)
                homeObservable.fetchTimerState(context: viewContext)
            }
    }
    
    @ViewBuilder
    var shortStats: some View {
        VStack {
            StatsLabel(title: NSLocalizedString("TotalWorkouts", comment: ""), value: String(homeObservable.totalNumberOfWorkouts))
        }
    }
    
    @ViewBuilder
    var lastTrainingInfo: some View {
        VStack {
            Text(NSLocalizedString("LatestResults", comment: ""))
                .font(.system(size: 20, weight: .semibold))
                .padding()
            
            ForEach(0..<homeObservable.infoOffsets.count, id: \.self) { index in
                TrainingInfoItem(workout: homeObservable.workoutList[index], clearCompletion: {
                    homeObservable.clearOffsetsExceptCurrent(index: index)
                }, deletionCompletion: {
                    showItemDeletionDialog {
                        if let uuid = homeObservable.workoutList[index].id {
                            homeObservable.removeTraining(shouldLimit: true, uuid: uuid, context: viewContext)
                        }
                        
                        homeObservable.fetchLatestTrainingItems(shouldLimit: true, context: viewContext)
                    }
                }, infoOffset: $homeObservable.infoOffsets[index])
            }
        }
    }
}
