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
                .colorMultiply(Color(isTrainingPaused ? "Warning" : (isTrainingStarted ? "Success" : "Danger")))
                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
            
            Text(NSLocalizedString(isTrainingPaused ? "ResumeTraining" : (isTrainingStarted ? "PauseTraining" : "StartTraining"), comment: ""))
                .multilineTextAlignment(.center)
            
            if isTrainingPaused {
                SolidButton(text: NSLocalizedString("FinishTraining", comment: "")) {
                    finishTrainingCompletion()
                }
            }
        }.frame(maxWidth: .infinity)
            .background(Color("Background"))
    }
}
