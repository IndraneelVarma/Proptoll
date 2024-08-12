import SwiftUI
import Combine

struct OtpFieldView: View {
    @Binding var otp: String
    let numberOfFields: Int
    
    @FocusState private var focusedField: Int?
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<numberOfFields, id: \.self) { index in
                TextField("", text: binding(for: index))
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: index)
                    .onChange(of: otp) { oldValue, newValue in
                        handleOtpChange(oldValue: oldValue, newValue: newValue, index: index)
                    }
            }
        }
    }
    
    private func binding(for index: Int) -> Binding<String> {
        return Binding<String>(
            get: {
                if index < self.otp.count {
                    return String(self.otp[self.otp.index(self.otp.startIndex, offsetBy: index)])
                }
                return ""
            },
            set: { newValue in
                var currentOTP = self.otp
                
                // Ensure we don't exceed the number of fields
                if currentOTP.count > numberOfFields {
                    currentOTP = String(currentOTP.prefix(numberOfFields))
                }
                
                // Handle deletion
                if newValue.isEmpty {
                    if index < currentOTP.count {
                        currentOTP.remove(at: currentOTP.index(currentOTP.startIndex, offsetBy: index))
                    }
                } else if let digit = newValue.last, digit.isNumber {
                    // Ensure only one digit per field
                    let filteredNewValue = String(digit)
                    
                    if index < numberOfFields {
                        if index < currentOTP.count {
                            currentOTP.remove(at: currentOTP.index(currentOTP.startIndex, offsetBy: index))
                        }
                        currentOTP.insert(contentsOf: filteredNewValue, at: currentOTP.index(currentOTP.startIndex, offsetBy: index))
                    }
                }
                
                // Update the OTP state
                self.otp = currentOTP
            }
        )
    }
    
    private func handleOtpChange(oldValue: String, newValue: String, index: Int) {
        if newValue.count > oldValue.count {
            focusedField = min(newValue.count, numberOfFields - 1)
        } else if newValue.count < oldValue.count {
            focusedField = max(newValue.count - 1, 0)
        }
    }
}

#Preview {
   LoginView()
}
