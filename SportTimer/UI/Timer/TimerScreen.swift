//
//  TimerScreen.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct TimerScreen: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var timerObservable = TimerObservable()
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                
                    timerIndicator.padding(.vertical, 20)
                
                    TrainingButton(isTrainingStarted: $timerObservable.isTrainingStarted,
                                   isTrainingPaused: $timerObservable.isTrainingPaused,
                                   finishTrainingCompletion: {
                        showConfirmationDialog {
                            timerObservable.finishTraining(context: viewContext)
                        }
                    }).onTapGesture {
                        if !timerObservable.isTrainingStarted {
                            timerObservable.shouldPresentModeSelection = true
                        } else {
                            timerObservable.handleTrainingButtonAction(context: viewContext)
                        }
                    }
                
                    trainingDescription
                
                }.frame(maxWidth: .infinity)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if timerObservable.nowLoading {
                NowLoading()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .actionSheet(isPresented: $timerObservable.shouldPresentModeSelection) {
                ActionSheet(title: Text(NSLocalizedString("TrainingMode", comment: "")), message: nil, buttons: timerObservable.trainingModesList)
            }.onAppear {
                timerObservable.setupTrainingModesList(context: viewContext)
                timerObservable.fetchTimerState(context: viewContext)
                timerObservable.startTimer(context: viewContext)
            }.onDisappear {
                timerObservable.stopTimer()
            }.background(Color("Background"))
    }
    
    @ViewBuilder
    var timerIndicator: some View {
        let currentDegrees = timerObservable.currentTimerSeconds % 60
        
        ZStack {
            SolidArc(startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                .stroke(.gray.opacity(0.25), style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.width - 60)
            
            SolidArc(startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(currentDegrees * 6)), clockwise: true)
                .stroke(.green, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.width - 60)
            
            Text(timerObservable.formattedTimerString)
                .font(.system(size: 30, weight: .black))
                .padding()
        }.frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    var trainingDescription: some View {
        let margin: CGFloat = 16
        
        TextEditor(text: $timerObservable.descriptionText)
            .frame(width: UIScreen.main.bounds.width - margin * 2,
                   height: UIScreen.main.bounds.height / 3)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("Secondary"), lineWidth: 3))
    }
}
