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
        let margin: CGFloat = 16
        
        ZStack {
            HStack {
                HStack {
                    
                }.frame(maxWidth: (UIScreen.main.bounds.width - margin * 2) * 2 / 3, maxHeight: .infinity)
                
                HStack {
                    Text(NSLocalizedString("Delete", comment: ""))
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 16)
                        .foregroundColor(.white)
                }.frame(maxWidth: (UIScreen.main.bounds.width - margin * 2) / 3, maxHeight: .infinity)
                    .background(Color("Danger"))
                    .onTapGesture {
                        infoOffset = 0
                        
                        deletionCompletion()
                    }
            }.frame(maxWidth: UIScreen.main.bounds.width - margin * 2, maxHeight: .infinity)
                .background(Color("Danger"))
                .cornerRadius(8)
            
            infoContents
            
        }.frame(width: UIScreen.main.bounds.width - margin * 2)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("Secondary"), lineWidth: 3))
            .padding(.vertical, 8)
            .clipped()
            .highPriorityGesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onChanged{ value in
                clearCompletion()
                
                let horizontal = value.translation.width
                
                if horizontal <= 0, horizontal >= -(UIScreen.main.bounds.width - margin * 2) / 3 {
                    infoOffset = horizontal
                }
            }.onEnded { value in
                clearCompletion()
                
                let horizontal = value.translation.width
                
                if horizontal <= -(UIScreen.main.bounds.width - margin * 2) / 6 {
                    infoOffset = -(UIScreen.main.bounds.width - margin * 2) / 3
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
        let margin: CGFloat = 16
        
        VStack(alignment: .leading) {
            
            StatsLabel(title: NSLocalizedString("TrainingDate", comment: ""), value: workoutDate).padding(.vertical, 8)
            
            StatsLabel(title: NSLocalizedString("TrainingDuration", comment: ""), value: workoutDuration).padding(.vertical, 8)
            
            StatsLabel(title: NSLocalizedString("TrainingMode", comment: ""), value: workout.type ?? "Other").padding(.vertical, 8)
            
            Text(workout.notes ?? NSLocalizedString("NoTrainingNotes", comment: ""))
                .font(.system(size: 16, weight: .thin))
                .padding(.horizontal, 16).padding(.vertical, 8)
        }.frame(width: UIScreen.main.bounds.width - margin * 2)
            .background(Color("Background"))
            .offset(x: infoOffset, y: 0)
            .animation(Animation.default.speed(1))
    }
}
