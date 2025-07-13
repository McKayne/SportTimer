//
//  TrainingInfoItem.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct TrainingInfoItem: View {
    
    var workout: Workout
    
    @State var workoutDate: String = ""
    @State var workoutDuration: String = ""
    
    var clearCompletion: () -> Void
    
    var deletionCompletion: () -> Void
    
    @Binding var infoOffset: CGFloat
    
    var body: some View {
        ZStack {
            HStack {
                HStack {
                    
                }.frame(maxWidth: (UIScreen.main.bounds.width - 40) * 2 / 3, maxHeight: .infinity)
                
                HStack {
                    Text(NSLocalizedString("Delete", comment: ""))
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                }.frame(maxWidth: (UIScreen.main.bounds.width - 40) / 3, maxHeight: .infinity)
                    .background(.red)
                    .onTapGesture {
                        infoOffset = 0
                        
                        deletionCompletion()
                    }
            }.frame(maxWidth: UIScreen.main.bounds.width - 40, maxHeight: .infinity)
                .background(.red)
                .cornerRadius(8)
            
            infoContents
            
        }.frame(width: UIScreen.main.bounds.width - 40)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.pink, lineWidth: 3))
            .padding(.vertical, 8)
            .clipped()
            .highPriorityGesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onChanged{ value in
                clearCompletion()
                
                let horizontal = value.translation.width
                
                if horizontal <= 0, horizontal >= -(UIScreen.main.bounds.width - 40) / 3 {
                    infoOffset = horizontal
                }
            }.onEnded { value in
                clearCompletion()
                
                let horizontal = value.translation.width
                
                if horizontal <= -(UIScreen.main.bounds.width - 40) / 6 {
                    infoOffset = -(UIScreen.main.bounds.width - 40) / 3
                } else {
                    infoOffset = 0
                }
            }).task {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy HH:mm"
                
                if let date = workout.date {
                    workoutDate = formatter.string(from: date)
                }
                
                if workout.duration >= 3600 {
                    workoutDuration = String(format: "%02d", workout.duration / 3600) + ":" + String(format: "%02d", workout.duration / 60 % 60) + ":" + String(format: "%02d", workout.duration % 60)
                } else {
                    workoutDuration = String(format: "%02d", workout.duration / 60 % 60) + ":" + String(format: "%02d", workout.duration % 60)
                }
            }.shadow(radius: 12)
    }
    
    @ViewBuilder
    var infoContents: some View {
        VStack(alignment: .leading) {
            
            StatsLabel(title: NSLocalizedString("TrainingDate", comment: ""), value: workoutDate).padding(.vertical, 8)
            
            StatsLabel(title: NSLocalizedString("TrainingDuration", comment: ""), value: workoutDuration).padding(.vertical, 8)
            
            StatsLabel(title: NSLocalizedString("TrainingMode", comment: ""), value: workout.type ?? "Other").padding(.vertical, 8)
            
            Text(workout.notes ?? NSLocalizedString("NoTrainingNotes", comment: ""))
                .font(.system(size: 16, weight: .thin))
                .padding(.horizontal, 20).padding(.vertical, 8)
        }.frame(width: UIScreen.main.bounds.width - 40)
            .background(.white)
            .offset(x: infoOffset, y: 0)
    }
}
