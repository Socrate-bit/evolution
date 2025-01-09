//
//  performance_widgetLiveActivity.swift
//  performance_widget
//
//  Created by Lucas Soullier  on 08/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct performance_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct performance_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: performance_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension performance_widgetAttributes {
    fileprivate static var preview: performance_widgetAttributes {
        performance_widgetAttributes(name: "World")
    }
}

extension performance_widgetAttributes.ContentState {
    fileprivate static var smiley: performance_widgetAttributes.ContentState {
        performance_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: performance_widgetAttributes.ContentState {
         performance_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: performance_widgetAttributes.preview) {
   performance_widgetLiveActivity()
} contentStates: {
    performance_widgetAttributes.ContentState.smiley
    performance_widgetAttributes.ContentState.starEyes
}
