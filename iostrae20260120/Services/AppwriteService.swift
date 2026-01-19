import Foundation

class AppwriteService {
    static let shared = AppwriteService()
    
    private init() {}
    
    func fetchSubscriptions(completion: @escaping (Result<[Subscription], Error>) -> Void) {
        guard let url = URL(string: "\(Config.endpoint)/databases/\(Config.databaseId)/collections/\(Config.subscriptionCollectionId)/documents") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(Config.projectId, forHTTPHeaderField: "X-Appwrite-Project")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SubscriptionListResponse.self, from: data)
                completion(.success(result.documents))
            } catch {
                print("Decoding error: \(error)")
                if let str = String(data: data, encoding: .utf8) {
                    print("Raw response: \(str)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
}
