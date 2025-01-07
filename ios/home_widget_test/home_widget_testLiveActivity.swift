//
//  home_widget_testLiveActivity.swift
//  home_widget_test
//
//  Created by Lucas Soullier  on 04/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct home_widget_testAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct home_widget_testLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: home_widget_testAttributes.self) { context in
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

extension home_widget_testAttributes {
    fileprivate static var preview: home_widget_testAttributes {
        home_widget_testAttributes(name: "World")
    }
}

extension home_widget_testAttributes.ContentState {
    fileprivate static var smiley: home_widget_testAttributes.ContentState {
        home_widget_testAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: home_widget_testAttributes.ContentState {
         home_widget_testAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: home_widget_testAttributes.preview) {
   home_widget_testLiveActivity()
} contentStates: {
    home_widget_testAttributes.ContentState.smiley
    home_widget_testAttributes.ContentState.starEyes
}
