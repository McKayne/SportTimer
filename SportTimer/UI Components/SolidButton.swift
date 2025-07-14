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
        let margin: CGFloat = 16
        
        VStack {
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .padding()
        }.frame(width: UIScreen.main.bounds.width - margin * 2, height: 50)
            .background(Color("Secondary"))
            .cornerRadius(8)
            .onTapGesture {
                actionHandler()
            }
    }
}
