//
//  EmailViewModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 14/10/24.
//

import Foundation
import Combine

class EmailViewModel: ObservableObject {
    @Published var updatedMail: Mail?
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    private let backgroundQueue = DispatchQueue(label: "com.app.backgroundQueue", qos: .background)
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "PATCH")) {
        self.apiService = apiService
    }
    
    func editMail(mailId: String) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            Task {
                await self.apiService.getData3(endpoint: "owners", body: ["email": mailId], query: ["filter[where][mobile_number]": UserDefaults.standard.string(forKey: "mainPhoneNumber") ?? ""])
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            self.error = error.localizedDescription
                            print("Error editing mail: \(error.localizedDescription)")
                        }
                    } receiveValue: { data in
                        do {
                            let updatedMail = try JSONDecoder().decode(Mail.self, from: data)
                            self.updatedMail = updatedMail
                            print("Mail updated successfully: \(updatedMail)")
                        } catch {
                            self.error = "Failed to decode updated mail: \(error.localizedDescription)"
                            print("Error decoding updated mail: \(error.localizedDescription)")
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }
    }
}
