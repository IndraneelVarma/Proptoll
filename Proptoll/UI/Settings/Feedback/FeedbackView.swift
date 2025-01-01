import SwiftUI

struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var isSubmitting = false
    private let characterLimit = 200

    
    var body: some View {
        ZStack {
            Color.mainTheme
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Feedback text section
                VStack(alignment: .center, spacing: 16) {
                    Text("Share your feedback")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $feedbackText)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                            .stroke(.primary, lineWidth: 0.25)
                        )
                        .frame(height: 150)
                    
                    // Character count indicator
                    Text("\(feedbackText.count)/\(characterLimit)")
                        .font(.custom("Montserrat-Regular", size: 13))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // Custom gradient button
                Button(action: submitFeedback) {
                    HStack {
                        Text("Submit")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundStyle(.white)
                        
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 35)
                            .foregroundStyle(isSubmitting == false ? LinearGradient(
                                colors: [Color("lavender500"), Color("BluePurple")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : LinearGradient(
                                colors: [.gray, .gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                }
                .disabled(isSubmitting)
                .tint(.primary)
            }
            .padding(24)
        }
    }
    
    private func submitFeedback() {
        // Implement feedback submission logic here
        isSubmitting = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isSubmitting = false
        }
    }
}

#Preview {
    FeedbackView()
}
