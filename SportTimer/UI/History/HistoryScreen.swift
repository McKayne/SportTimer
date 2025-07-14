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
            VStack {
                
                let margin: CGFloat = 16
                
                TextField("Search", text: $historyObservable.searchFilter)
                    .frame(width: UIScreen.main.bounds.width - margin * 2,
                           height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Secondary"), lineWidth: 3))
                    .zIndex(10)
                    .onChange(of: historyObservable.searchFilter) { _ in
                        historyObservable.fetchLatestTrainingItems(shouldLimit: false, context: viewContext, searchFilter: historyObservable.searchFilter)
                    }
            
                ScrollView {
                    VStack {
                        
                        ForEach(0..<historyObservable.workoutHistoryGroups.keys.count, id: \.self) { groupIndex in
                            let key = Array(historyObservable.workoutHistoryGroups.keys)[groupIndex]
                            
                            Text(key)
                                .font(.system(size: 16, weight: .semibold))
                                .padding()
                            
                            if let workoutGroup = historyObservable.workoutHistoryGroups[key] {
                                ForEach(0..<workoutGroup.count, id: \.self) { index in
                                    TrainingInfoItem(workout: workoutGroup[index], clearCompletion: {                                            historyObservable.clearOffsetsExceptCurrent(groupIndex: groupIndex, index: index)
                                    }, deletionCompletion: {
                                        showItemDeletionDialog {
                                            if let uuid = workoutGroup[index].id {
                                                historyObservable.searchFilter = ""
                                                historyObservable.removeTraining(uuid: uuid, context: viewContext)
                                            }
                                        }
                                    }, infoOffset: $historyObservable.groupInfoOffsets[groupIndex][index])
                                }
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if historyObservable.nowLoading {
                NowLoading()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                historyObservable.fetchLatestTrainingItems(context: viewContext)
            }.background(Color("Background"))
    }
}
