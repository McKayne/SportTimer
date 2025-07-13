//
//  StatisticsScreen.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct StatisticsScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var statisticsObservable = StatisticsObservable()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                
                    ForEach(0..<statisticsObservable.workoutTypes.count, id: \.self) { index in
                        let key = Array(statisticsObservable.workoutTypes.keys)[index]
                        StatsLabel(title: key, value: String(statisticsObservable.workoutTypes[key] ?? 0))
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if statisticsObservable.nowLoading {
                NowLoading()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                statisticsObservable.fetchTypeStats(context: viewContext)
            }
    }
}
