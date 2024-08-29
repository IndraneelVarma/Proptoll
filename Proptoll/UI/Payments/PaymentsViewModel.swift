//
//  PaymentsViewModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 29/08/24.
//

import Foundation
import Combine

class PaymentsViewModel: ObservableObject {
    @Published var payments: [Pay] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchOwner(jsonQuery: [String: Any]) async {
        await apiService.getData2(endpoint: "iosPaymentResponse", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (payment: [Pay]) in
                self?.payments = payment
            }
            .store(in: &cancellables)
    }
}
