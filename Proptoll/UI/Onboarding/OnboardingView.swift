import SwiftUI

struct OnboardingOverlay: View {
    @Binding var isVisible: Bool
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.mainTheme
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    Spacer()
                    
                    TabView(selection: $currentPage) {
                        WelcomeStep()
                            .tag(0)
                        
                        AccountStep()
                            .tag(1)
                        
                        NoticeBoardStep()
                            .tag(2)
                        
                        InvoicesStep()
                            .tag(3)
                        
                        ReceiptsStep()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: geometry.size.height * 0.8)
                    
                    Spacer()
                    
                    NavigationButtons(
                        currentPage: $currentPage,
                        isVisible: $isVisible,
                        totalPages: 5,
                        screenWidth: geometry.size.width
                    )
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .transition(.opacity)
    }
}

// Navigation Buttons Component
struct NavigationButtons: View {
    @Binding var currentPage: Int
    @Binding var isVisible: Bool
    let totalPages: Int
    let screenWidth: CGFloat
    @State private var buttonScale: CGFloat = 1
    
    var body: some View {
        HStack {
            if currentPage < totalPages - 1 {
                Button(action: handleSkip) {
                    Text("Skip")
                        .font(.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.primary.opacity(0.8))
                        .frame(width: 100, height: 50)
                }
            } else {
                Spacer()
                    .frame(width: 100)
            }
            
            Spacer()
            
            Button(action: handleNextButton) {
                Text(currentPage < totalPages - 1 ? "Next" : "Get Started")
                    .font(.custom("Montserrat-SemiBold", size: 16))
                    .foregroundColor(.white)
                    .frame(width: 140, height: 50)
                    .background(Color.bluePurple)
                    .cornerRadius(10)
                    .scaleEffect(buttonScale)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)
        }
        .padding(.horizontal, 20)
        .frame(width: screenWidth)
    }
    
    private func handleNextButton() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            buttonScale = 0.9
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                buttonScale = 1
                if currentPage < totalPages - 1 {
                    currentPage += 1
                } else {
                    UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                    isVisible = false
                }
            }
        }
    }
    
    private func handleSkip() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        isVisible = false
    }
}

// Base Onboarding Step
struct OnboardingStepView<Content: View>: View {
    let title: String
    let description: String
    let systemImage: String
    @ViewBuilder let additionalContent: () -> Content
    
    @State private var isAnimated = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.bluePurple)
                .scaleEffect(isAnimated ? 1 : 0.5)
                .opacity(isAnimated ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isAnimated ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            
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
            
            additionalContent()
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 20)
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


struct OnboardingStepView3<Content: View>: View { //for asset images
    let title: String
    let description: String
    let systemImage: String
    @ViewBuilder let additionalContent: () -> Content
    
    @State private var isAnimated = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemImage)
                .resizable()
                .scaledToFit()
                .frame(height: 360)
                .foregroundColor(.bluePurple)
                .scaleEffect(isAnimated ? 1 : 0.5)
                .opacity(isAnimated ? 1 : 0)
                .padding(.bottom, -50)
            
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
            
            additionalContent()
                .opacity(isAnimated ? 1 : 0)
                .offset(y: isAnimated ? 0 : 20)
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






