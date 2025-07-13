//
//  TrainingButton.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct TrainingButton: View {
    
    @Binding var isTrainingStarted: Bool
    @Binding var isTrainingPaused: Bool
    
    var finishTrainingCompletion: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "power")
                .resizable()
                .colorInvert()
                .colorMultiply(isTrainingPaused ? .orange : (isTrainingStarted ? .green : .red))
                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
            
            Text(isTrainingPaused ? "Tap to resume training" : (isTrainingStarted ? "Tap to pause training" : "Tap to start training"))
                .multilineTextAlignment(.center)
            
            if isTrainingPaused {
                SolidButton(text: "Finish training") {
                    finishTrainingCompletion()
                }
            }
        }.frame(maxWidth: .infinity)
            .background(.white)
    }
}
