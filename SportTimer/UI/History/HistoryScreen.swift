//
//  HistoryScreen.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct HistoryScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var historyObservable = HistoryObservable()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                
                    ForEach(0..<historyObservable.infoOffsets.count, id: \.self) { index in
                        TrainingInfoItem(workout: historyObservable.workoutList[index], clearCompletion: {
                            historyObservable.clearOffsetsExceptCurrent(index: index)
                        }, deletionCompletion: {
                            showItemDeletionDialog {
                                if let uuid = historyObservable.workoutList[index].id {
                                    historyObservable.removeTraining(shouldLimit: false, uuid: uuid, context: viewContext)
                                }
                            }
                        }, infoOffset: $historyObservable.infoOffsets[index])
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if historyObservable.nowLoading {
                NowLoading()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                historyObservable.fetchLatestTrainingItems(shouldLimit: false, context: viewContext)
            }
    }
}
