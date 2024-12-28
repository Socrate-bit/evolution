//
//  test_homeLiveActivity.swift
//  test_home
//
//  Created by Lucas Soullier  on 28/12/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct test_homeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct test_homeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: test_homeAttributes.self) { context in
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

extension test_homeAttributes {
    fileprivate static var preview: test_homeAttributes {
        test_homeAttributes(name: "World")
    }
}

extension test_homeAttributes.ContentState {
    fileprivate static var smiley: test_homeAttributes.ContentState {
        test_homeAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: test_homeAttributes.ContentState {
         test_homeAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: test_homeAttributes.preview) {
   test_homeLiveActivity()
} contentStates: {
    test_homeAttributes.ContentState.smiley
    test_homeAttributes.ContentState.starEyes
}
