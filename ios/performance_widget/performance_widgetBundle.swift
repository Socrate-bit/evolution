//
//  performance_widgetBundle.swift
//  performance_widget
//
//  Created by Lucas Soullier  on 08/01/2025.
//

import WidgetKit
import SwiftUI

@main
struct performance_widgetBundle: WidgetBundle {
    var body: some Widget {
        performance_widget()
        performance_widgetControl()
        performance_widgetLiveActivity()
    }
}
