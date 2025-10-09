//
//  SplashView.swift
//  HatchVideoFeed
//
//  Created by Mayuri Patel on 2025-10-09.
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.5
    @Binding var showFeed: Bool

    var body: some View {
            ZStack {
                
                Color.white
                    .ignoresSafeArea()
                
                
                VStack {
                    Spacer()
                    
                    // App logo
                    Image("AppLogo") //
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .onAppear {
                            // Animate logo smoothly
                            withAnimation(.easeInOut(duration: 1.2)) {
                                logoScale = 1.0
                                logoOpacity = 1.0
                            }
                            
                            // Stay for a bit before moving on
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    showFeed = true
                                }
                            }
                        }
                    
                    Spacer()
                }
            }
    }
    
}
