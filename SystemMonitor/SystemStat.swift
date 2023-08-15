//
//  SystemStat.swift
//  SystemMonitor
//
//  Created by Ivy Jackson on 8/15/23.
//

import Foundation
struct SystemStat: Codable {
    let memoryUsed: Double
    let cpuPercent: Double
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case memoryUsed = "memory_used"
        case cpuPercent = "cpu_percent"
        case date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        memoryUsed = try container.decode(Double.self, forKey: .memoryUsed)
        cpuPercent = try container.decode(Double.self, forKey: .cpuPercent)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        if let date = dateFormatter.date(from: dateString) {
            self.date = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Invalid date format")
        }
    }
}
