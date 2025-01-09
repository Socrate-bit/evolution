//
//  performance_widget.swift
//  performance_widget
//
//  Created by Lucas Soullier  on 08/01/2025.
//

import SwiftUI
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), name: "No Stat", actualValue: "-", maxValue: "-", color: 4_284_513_675)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(),
            name: "No Stat", actualValue: "-", maxValue: "-", color: 4_284_513_675)
       
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) -> Timeline<SimpleEntry> {
        let userDefaults = UserDefaults(suiteName: "group.productive")
        
        let statsDataJson = userDefaults?.value(forKey: configuration.name?.id ?? "")
        let statData = parseStatData(from: statsDataJson as! String? ?? "")
        
        
        let entry = SimpleEntry(date: Date(),
                                name: configuration.name?.name ?? "-", actualValue: statData?.actualValue ?? "-", maxValue: statData?.maxValue ?? "-",
                                color: UInt32(statData?.color ?? "4284513675") ?? 0)
       return Timeline(entries: [entry], policy: .never)  // No updates
    }
}

struct StatData: Decodable {
    var color: String
    var actualValue: String
    var maxValue: String
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let name: String
    let actualValue: String
    let maxValue: String
    let color: UInt32
}

func parseStatData(from json: String) -> StatData? {
    guard let jsonData = json.data(using: .utf8) else {
        return nil
    }

    let decoder = JSONDecoder()
    do {
        let statData = try decoder.decode(StatData.self, from: jsonData)
        return statData
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

extension UIColor {
    convenience init(argb: UInt32) {
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255.0
        let red = CGFloat((argb >> 16) & 0xFF) / 255.0
        let green = CGFloat((argb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(argb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

struct performance_widgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Rectangle()
                    .frame(width: geometry.size.width + 36, height: geometry.size.height + 36)
                    .foregroundColor(
                        Color(UIColor(argb: entry.color))).position(
                            x: geometry.size.width / 2, y: geometry.size.height / 2)

                VStack(alignment: .center) {
                    Text(entry.actualValue)
                        .foregroundColor(.white)
                        .font(.largeTitle).bold()
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer().frame(height: 6)
                    
                    Text(entry.name)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .truncationMode(.tail)
                    
                    Spacer().frame(height: 6)
                    
                    Text(("Last week: \(entry.maxValue)"))
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .truncationMode(.tail)

                }
                    .widgetBackground(Color.white)
            }
        }
    }
}

struct performance_widget: Widget {
    let kind: String = "performance_widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self,  provider: Provider()) { entry in
            performance_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Stats widget")
        .description("This widget displays static content.")
    }
}

struct performance_widget_Previews: PreviewProvider {
    static var previews: some View {
        performance_widgetEntryView(entry: SimpleEntry(date: Date(),
            name: "AVG Produced", actualValue: "3.75", maxValue: "6.83", color: 4_278_430_196))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


