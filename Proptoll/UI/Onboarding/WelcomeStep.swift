//
//  WelcomeStep.swift
//  Proptoll
//
//  Created by Indraneel Varma on 26/11/24.
//

import SwiftUI
struct WelcomeStep: View {
    @State private var waveEffect = false
    
    var body: some View {
        OnboardingStepView2(
            title: "Welcome to Proptoll",
            description: "Let's take a quick tour of the app! We'll show you the main sections of our app so that you can make the most of your experience.",
            systemImage: "sparkles"
        ) {
            Image(.proptollIcon)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.bluePurple)
               /* .rotationEffect(.degrees(waveEffect ? 20 : -20))
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                    value: waveEffect
                )
                .onAppear { waveEffect = true } */
        }
    }
}

struct OnboardingStepView2<Content: View>: View {
    let title: String
    let description: String
    let systemImage: String
    @ViewBuilder let additionalContent: () -> Content
    @State private var isAnimated = false
    
    var body: some View {
        
        VStack(spacing: 24) {
            additionalContent()
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 20)
            
            Text(title)
                .font(.custom("Montserrat-Bold", size: 24))
                .foregroundColor(.primary)
                .offset(y: isAnimated ? 0 : 20)
                .opacity(isAnimated ? 1 : 0)
            
            Text(description)
                .font(.custom("Montserrat-Regular", size: 16))
                .foregroundColor(.primary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .offset(y: isAnimated ? 0 : 20)
                .opacity(isAnimated ? 1 : 0)
            
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                
            
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                isAnimated = true
            }
        }
        .onDisappear {
            isAnimated = false
        }
    }
}

