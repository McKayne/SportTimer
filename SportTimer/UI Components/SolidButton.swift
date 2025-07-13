//
//  SolidButton.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct SolidButton: View {
    
    var text: String
    
    var actionHandler: () -> Void
    
    var body: some View {
        VStack {
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .padding()
        }.frame(width: UIScreen.main.bounds.width - 40, height: 50)
            .background(.pink)
            .cornerRadius(8)
            .onTapGesture {
                actionHandler()
            }
    }
}
