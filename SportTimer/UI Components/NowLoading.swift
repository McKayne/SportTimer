//
//  NowLoading.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/13/25.
//

import SwiftUI

struct NowLoading: View {
    
    var body: some View {
        ZStack {
            ZStack {
                Text("Loading...")
                    .font(.system(size: 20, weight: .semibold))
                    .padding()
            }.frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.15)
                .background(.white)
                .cornerRadius(12)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.75))
    }
}
