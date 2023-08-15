//
//  ContentView.swift
//  SystemMonitor
//
//  Created by Ivy Jackson on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var systemStats: [SystemStat] = []
    
    var body: some View {
        VStack {
            Text("\(systemStats.count)")
            
            Button("Get system status", action: fetchSystemStats)
        }
        .padding()
    }
    
    func fetchSystemStats() {
        fetchSystemStats { stats, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let stats = stats {
                systemStats = stats
            }
        }
    }
    
    func fetchSystemStats(completion: @escaping ([SystemStat]?, Error?) -> Void) {
        guard let url = URL(string: Constants.api_base) else {
            // Handle URL creation failure
            completion(nil, NSError(domain: "com.example.api", code: -1, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle network error
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                // Handle missing data
                completion(nil, NSError(domain: "com.example.api", code: -2, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let systemStats = try decoder.decode([SystemStat].self, from: data)
                completion(systemStats, nil)
            } catch {
                // Handle decoding error
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
