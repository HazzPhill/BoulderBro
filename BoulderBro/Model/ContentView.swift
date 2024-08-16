//
//  ContentView.swift
//  BoulderBro
//
//  Created by Hazz on 12/08/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                SplashScreen()
            } else {
                LogInView()
            }
        }
    }
}

#Preview {
    ContentView()
}

