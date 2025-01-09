//
//  AppIntent.swift
//  performance_widget
//
//  Created by Lucas Soullier  on 08/01/2025.
//

import WidgetKit
import AppIntents

var allStats: [WidgetStat] = []

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Select stat" }

    // An example configurable parameter.
    @Parameter(title: "Stats")
    var name: WidgetStat?
}

struct WidgetStat: AppEntity {
    var id: String
    var name: String
    
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Stat"
    static var defaultQuery =  WidgetStatQuery()
    
    var displayRepresentation: DisplayRepresentation {DisplayRepresentation(title: "\(name)")}
    

    
    static let allStats: [WidgetStat] = [
        WidgetStat(id: "2d829d62-985f-4354-adfc-33af9b49e540", name: "Completion"),
        WidgetStat(id: "2", name: "Produced")
    ]
}

struct WidgetStatQuery: EntityQuery {
    func entities(for identifiers: [WidgetStat.ID]) async throws -> [WidgetStat] {
        allStats.filter {identifiers.contains($0.id)}
    }
    
    func suggestedEntities() async throws -> [WidgetStat] {
        allStats = getAllStatsConfiguration() ?? []
        return allStats
    
    }
    
    func defaultResult() async -> WidgetStat? {
        WidgetStat.allStats.first
    }
}

func getAllStatsConfiguration() -> [WidgetStat]? {
    let userDefaults = UserDefaults(suiteName: "group.productive")
    let available_stats = userDefaults?.string(forKey: "available_stats")

    let allStats: [WidgetStat] = parseWidgetStats(from: available_stats ?? "") ?? []
    return allStats
}

func parseWidgetStats(from jsonString: String) -> [WidgetStat]? {
    // Convert JSON string to Data
    if let jsonData = jsonString.data(using: .utf8) {
        do {
            // Decode JSON into an array of dictionaries
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                // Map each dictionary to a WidgetStat object
                return jsonArray.compactMap { dict in
                    if let id = dict["id"] as? String, let name = dict["name"] as? String {
                        return WidgetStat(id: id, name: name)
                    }
                    return nil
                }
            }
        } catch {
            print("Error decoding JSON1: \(error)")
        }
    }
    return nil
}
