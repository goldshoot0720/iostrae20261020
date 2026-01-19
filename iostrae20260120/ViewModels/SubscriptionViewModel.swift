import Foundation
import SwiftUI
import Combine

class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchSubscriptions() {
        isLoading = true
        errorMessage = nil
        AppwriteService.shared.fetchSubscriptions { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let documents):
                    // Step 3: Sort by date near to far
                    self?.subscriptions = documents.sorted {
                        ($0.nextDateObject ?? Date.distantFuture) < ($1.nextDateObject ?? Date.distantFuture)
                    }
                    
                    // Trigger notifications check
                    NotificationManager.shared.scheduleNotifications(for: documents)
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
