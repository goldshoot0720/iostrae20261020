import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.name)
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let account = subscription.account, !account.isEmpty {
                    Text(account)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(subscription.site)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("$\(subscription.price)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let date = subscription.nextDateObject {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(isExpiringSoon(date) ? .red : .gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func isExpiringSoon(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let diff = calendar.dateComponents([.day], from: now, to: date).day ?? 100
        return diff >= 0 && diff <= 3
    }
}
