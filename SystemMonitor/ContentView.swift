//
//  ContentView.swift
//  SystemMonitor
//
//  Created by Ivy Jackson on 8/15/23.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @State var systemStats: [SystemStat] = []
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            VStack {
                TabView {
                    VStack {
                        // "Memory: \(systemStats.last?.memoryUsed ?? 0.0)%"
                        Text(String(format: "Memory: %.2f%%", systemStats.last?.memoryUsed ?? 0.0))
                        Chart {
                            ForEach(systemStats, id: \.date) { stat in
                                LineMark(
                                    x: .value("Date", stat.date), y: .value( "Percent", stat.memoryUsed)
                                )
                            }
                        }.chartYScale(domain: 0...100)
                    }
                    
                    VStack {
                        Text(String(format: "CPU: %.2f%%", systemStats.last?.cpuPercent ?? 0.0))
                        Chart {
                            ForEach(systemStats, id: \.date) { stat in
                                LineMark(
                                    x: .value("Date", stat.date), y: .value( "Percent", stat.cpuPercent)
                                )
                            }
                        }.chartYScale(domain: 0...100)
                    }
                }
                .tabViewStyle(PageTabViewStyle())

            }.padding(.horizontal, 16)
                .frame(height: 200)
                .onReceive(timer) { input in
                    fetchSystemStats()
                }
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
