import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            viewModel.fetchSubscriptions()
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.subscriptions) { sub in
                                SubscriptionRowView(subscription: sub)
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        viewModel.fetchSubscriptions()
                    }
                }
            }
            .navigationTitle("Subscriptions")
            .onAppear {
                viewModel.fetchSubscriptions()
            }
        }
        .navigationViewStyle(.stack)
    }
}
