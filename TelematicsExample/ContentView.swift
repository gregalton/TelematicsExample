//
//  ContentView.swift
//  TelematicsExample
//
//  Created by Greg Alton on 3/28/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Text("Drive Safely!")
                .font(.system(.title))
        }
        .padding()
        .onAppear() {
            TelematicsManager.shared.startTracking()
        }
    }
}

#Preview {
    ContentView()
}
