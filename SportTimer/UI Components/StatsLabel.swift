//
//  StatsLabel.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI

struct StatsLabel: View {
    
    var title: String
    
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .padding(.leading, 16)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .thin))
                .padding(.trailing, 16)
        }.frame(maxWidth: .infinity)
    }
}
