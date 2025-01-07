//
//  home_widget_test.swift
//  home_widget_test
//
//  Created by Lucas Soullier  on 04/01/2025.
//

import SwiftUI
import WidgetKit

class Schedule: Decodable {
    var timesOfTheDay: [Date?]?

    init(timesOfTheDay: [Date?]?) {
        self.timesOfTheDay = timesOfTheDay
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timesOfTheDayStrings = try? container.decode([String?]?.self, forKey: .timesOfTheDay)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if timesOfTheDayStrings == nil {
            self.timesOfTheDay = nil
        } else {
            self.timesOfTheDay = timesOfTheDayStrings?.compactMap {
                if $0 == nil { return nil }
                return dateFormatter.date(from: $0!)
            }
        }}

    enum CodingKeys: String, CodingKey {
        case timesOfTheDay
    }
}

class Habit: Decodable, Hashable {
    var icon: String
    var name: String
    var color: UInt32
    var duration: TimeInterval?

    init(icon: String, name: String, color: UInt32, duration: TimeInterval?) {
        self.icon = icon
        self.name = name
        self.color = color
        self.duration = duration
    }

    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.name == rhs.name && lhs.color == rhs.color && lhs.duration == rhs.duration
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(color)
        hasher.combine(duration)
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

struct HabitData: Decodable {
    let habit: Habit
    let schedule: Schedule
    let validated: Bool?
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

class DisplayManager {
    var todayHabitsSchedule: [HabitData]
    var nextOtherDayHabit: HabitData?
    var actualHabitSchedule: HabitData?
    var dateTimeEnd: Date?
    var dateTimeStart: Date?
    var durationSinceStarted: TimeInterval?
    var durationLasting: TimeInterval?
    static let defaultDuration: TimeInterval = 3 * 60 * 60  // 3 hours in seconds
    var fillerColor: UIColor = .gray
    var habitName: String = "No schedule"
    var habitIcon: UInt32 = 61974
    var textCountDown: String = "Next habit:"
    var countDownData: Date?
    var isStarted: Bool? = nil

    init(todayHabitsSchedule: [HabitData], nextOtherDayHabit: HabitData?) {
        self.todayHabitsSchedule = todayHabitsSchedule
        self.nextOtherDayHabit = nextOtherDayHabit
    }

    func nextSchedule() {
        let currentDate = Date()

        for HabitData in todayHabitsSchedule {
            // Check if the habit is already done (you need to add this check based on your logic)
            // Here, assuming "done" status is checked through some method or property.

            // Get the habit duration and the start time from the schedule
            if (HabitData.validated == true) {
                continue
            }

            let habitDuration = HabitData.habit.duration ?? DisplayManager.defaultDuration
            var calendar = Calendar.current
            calendar.firstWeekday = 2
            let gregorianWeekday = calendar.component(.weekday, from: currentDate)

            let adjustedWeekday = (gregorianWeekday + 5) % 7 + 1
            
            
            if let timeStart = HabitData.schedule.timesOfTheDay?.element(at: adjustedWeekday - 1) ?? nil {
                let hour = calendar.component(.hour, from: timeStart)
                let minute = calendar.component(.minute, from: timeStart)

                let dateStart = Calendar.current.date(
                    bySettingHour: hour, minute: minute, second: 0, of: currentDate)!
                let dateEnd = dateStart.addingTimeInterval(habitDuration)

                // If the habit is past its end time, skip it
                if currentDate > dateEnd {
                    continue
                }

                // Set as scheduled habit
                _setScheduledHabit(habitSchedule: HabitData, start: dateStart, end: dateEnd)
                _initColor()
                break
            } else {
                // If there's no scheduled time, set as unscheduled habit
                _setUnscheduledHabit(habitSchedule: HabitData)
                break
            }
        }
    }

    func _setUnscheduledHabit(habitSchedule: HabitData) {
        actualHabitSchedule = habitSchedule
        durationSinceStarted = nil
        durationLasting = nil
        dateTimeEnd = nil
        habitIcon = UInt32(actualHabitSchedule?.habit.icon ?? String(habitIcon)) ?? habitIcon
        habitName = actualHabitSchedule?.habit.name ?? habitName

    }

    func _setScheduledHabit(habitSchedule: HabitData, start: Date, end: Date) {
        actualHabitSchedule = habitSchedule
        dateTimeStart = start
        dateTimeEnd = end
        durationSinceStarted = Date().timeIntervalSince(start)
        durationLasting = end.timeIntervalSince(Date())
        habitIcon = UInt32(actualHabitSchedule?.habit.icon ?? String(habitIcon)) ?? habitIcon
        habitName = actualHabitSchedule?.habit.name ?? habitName
    }

    func _initColor() {
        if let durationSinceStarted = durationSinceStarted, durationSinceStarted < 0 {
            fillerColor = .gray
        } else {
            fillerColor =
                actualHabitSchedule != nil
                ? UIColor(argb: actualHabitSchedule!.habit.color) : fillerColor
        }
    }

    func setCountDownTextDisplay() {
        if durationLasting == nil || durationLasting! <= 0 {
            textCountDown = "Next habit:"
            countDownData = nil
            isStarted = nil
        } else

        if durationSinceStarted! > 0 {
            textCountDown = "End in:"
            countDownData = dateTimeEnd
            isStarted = true

        } else {
            textCountDown = "Start in:"
            countDownData = dateTimeStart
            isStarted = false
        }
        _initColor()
    }
}

extension Collection {
    func element(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct HomeWidgetEntry: TimelineEntry {
    let date: Date
    let heightRatio: CGFloat
    let displayManager: DisplayManager

    init(
        date: Date, heightRatio: CGFloat, displayManager: DisplayManager

    ) {
        self.date = date
        self.heightRatio = heightRatio
        self.displayManager = displayManager

    }

}

func parseHabitData(from json: String) -> [HabitData]? {
    guard let jsonData = json.data(using: .utf8) else {
        return nil
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    do {
        let habitDataList = try decoder.decode([HabitData].self, from: jsonData)
        return habitDataList
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> HomeWidgetEntry {
        HomeWidgetEntry(
            date: Date(), heightRatio: 1.0,
            displayManager: DisplayManager(todayHabitsSchedule: [], nextOtherDayHabit: nil)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (HomeWidgetEntry) -> Void) {

        let displayManager = DisplayManager(todayHabitsSchedule: [], nextOtherDayHabit: nil)
        displayManager.nextSchedule()

        let entry = HomeWidgetEntry(
            date: Date(), heightRatio: 1.0, displayManager: displayManager)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HomeWidgetEntry>) -> Void)
    {
        var entries: [HomeWidgetEntry] = []

        let userDefaults = UserDefaults(suiteName: "group.productive")
        WidgetCenter.shared.reloadTimelines(ofKind: "home_widget_test")
        
        let title = userDefaults?.string(forKey: "todayHabitJson") ?? "No data"
        let titleTest = """
            [{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"d09707f8-0ade-47f2-b393-58f21ba38791","icon":"984437","name":"Wake-up routine","description":"## CONDITION\n- Straight from bed (Less than 10s)\n- Morning routine\n- Work after 25-50min after opening my eyes\n\n## PROCESS\n1. Stand-up straight from the bed (<2min)\n2. Shower / Cold shower / Prep / Clothes (8min)\n3. Food Hestia (2min)\n4. Clean environnement (3mim)\n5. /Think / Prep the day / Start working (10min)","newHabit":null,"frequency":5,"weekdays":["WeekDay.tuesday","WeekDay.friday","WeekDay.thursday","WeekDay.wednesday","WeekDay.monday"],"validationType":"HabitType.simple","startDate":"2024-11-03T00:00:00.000","endDate":"2025-11-03T00:00:00.000","timeOfTheDay":"7:0","additionalMetrics":["Time waking-up"],"ponderation":3,"orderIndex":0,"color":4294951175,"frequencyChanges":{"2024-11-07T00:00:00.000":6,"2024-11-12T00:00:00.000":5,"2024-11-14T00:00:00.000":6,"2024-11-16T00:00:00.000":7,"2024-11-20T00:00:00.000":6,"2024-11-25T00:00:00.000":5},"synced":false,"duration":60},"schedule":{"scheduleId":"ef1de0e4-c65c-4709-b172-7d9ddc284160","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"d09707f8-0ade-47f2-b393-58f21ba38791","startDate":"2025-01-04T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["tuesday","friday","thursday","wednesday","monday","saturday","sunday"],"timesOfTheDay":["9:0","9:0","9:0","9:0","9:0","9:0","9:0"],"notification":null},"validated":true},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"16fd90a8-6cfd-491b-bdb4-bb852bbe3ed2","icon":"58607","name":"Science (1.5-2)","description":"## CONDITIONS \n- >0.75 produced\n\n## DESCR\n- Deep science to improve brain function, complex problem solving (Math, Physic, Engineering etc.) \n- Deep science for LT project\n","newHabit":"- Consistency: 6 session per week","frequency":0,"weekdays":["WeekDay.tuesday","WeekDay.wednesday","WeekDay.monday","WeekDay.thursday","WeekDay.friday"],"validationType":"HabitType.recap","startDate":"2024-11-19T00:00:00.000","endDate":null,"timeOfTheDay":null,"additionalMetrics":[],"ponderation":4,"orderIndex":14,"color":4278430196,"frequencyChanges":{"2024-11-19T00:00:00.000":0},"synced":false,"duration":60},"schedule":{"scheduleId":"5c376cf8-426b-466f-9e57-0052bb24716d","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"16fd90a8-6cfd-491b-bdb4-bb852bbe3ed2","startDate":"2025-01-06T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["tuesday","monday","wednesday"],"timesOfTheDay":["9:25","9:25","9:25","9:25","9:25","9:25","9:25"],"notification":[0]},"validated":true},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"ec19ec68-f319-452f-be9a-86eb426fc671","icon":"984771","name":"Sport (50min)","description":"- M: High body ✅\n- Tu: MuayThai\n- W: Stretching ✅\n- Th: MuayThai\n- F: W1 - Low body / W2 - Running \n- S: MuayThai\n- Su: MuayThai alone ","newHabit":"- Consistency: Show-up everyday 5/6 days","frequency":6,"weekdays":["WeekDay.wednesday","WeekDay.friday","WeekDay.sunday","WeekDay.tuesday","WeekDay.monday","WeekDay.thursday"],"validationType":"HabitType.recap","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":"18:0","additionalMetrics":["Duration pause"],"ponderation":3,"orderIndex":4,"color":4293467747,"frequencyChanges":{"2024-11-07T00:00:00.000":5,"2024-11-12T00:00:00.000":6},"synced":false,"duration":60},"schedule":{"scheduleId":"7943981f-3117-440b-be64-e851a0b608f9","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"ec19ec68-f319-452f-be9a-86eb426fc671","startDate":"2025-01-04T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["monday","wednesday","friday","tuesday","thursday","saturday","sunday"],"timesOfTheDay":["11:40","11:40","11:40","11:40","11:40","11:40","11:40"],"notification":[20]},"validated":true},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"f48b8171-70ed-4b27-8bf5-8ff477b5854d","icon":"58735","name":"Meditation (12-25min)","description":"## CONDITION \n- All the routine \n- Present moment state\n\n## PROCESS\n- /Breathing exercises\n- Meditation exercises\n    - Focus arround \n    - Focus progressive sensorial \n    - Focus chakra \n    - Pause 2min \n    - Spe exercise: Self-visualisarion, Transcendental on breathing, Other ","newHabit":"Show-up everyday","frequency":6,"weekdays":["WeekDay.tuesday","WeekDay.friday","WeekDay.wednesday","WeekDay.monday","WeekDay.thursday","WeekDay.sunday"],"validationType":"HabitType.simple","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":"19:0","additionalMetrics":[],"ponderation":2,"orderIndex":5,"color":4293467747,"frequencyChanges":{"2024-11-07T00:00:00.000":5,"2024-11-15T00:00:00.000":6},"synced":false,"duration":60},"schedule":{"scheduleId":"a7e97351-5682-41d8-b9f6-58f374189516","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"f48b8171-70ed-4b27-8bf5-8ff477b5854d","startDate":"2025-01-04T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["tuesday","friday","wednesday","monday","thursday","sunday","saturday"],"timesOfTheDay":["13:10","13:10","13:10","13:10","13:10","13:10","13:10"],"notification":[20]},"validated":true},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"d324004b-2729-4bb7-805c-431eb430a444","icon":"984455","name":"Main path (4-8)","description":"## CONDITION\n- Quantity > 6\n- Most important actions\n\n## DESCRIPTION\n- Urgents things > Most imactful actions to reach the MT goals\n- Entrepreneurship / Deep science / Code / Tech","newHabit":"- Progressive testing: Testing & refactoring each module","frequency":5,"weekdays":["WeekDay.tuesday","WeekDay.friday","WeekDay.thursday","WeekDay.wednesday","WeekDay.monday"],"validationType":"HabitType.recap","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":"7:25","additionalMetrics":[],"ponderation":5,"orderIndex":1,"color":4278430196,"frequencyChanges":{"2024-11-07T00:00:00.000":6,"2024-11-12T00:00:00.000":5,"2024-11-14T00:00:00.000":6,"2024-11-25T00:00:00.000":5},"synced":false,"duration":60},"schedule":{"scheduleId":"a474bee6-91e6-45f6-8b68-ab9a31534d00","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"d324004b-2729-4bb7-805c-431eb430a444","startDate":"2025-01-04T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["tuesday","friday","thursday","wednesday","monday","saturday"],"timesOfTheDay":["14:10","14:10","14:10","14:10","14:10","14:10","14:10"],"notification":[20]},"validated":true},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"3b938204-b552-49dc-8640-4ebe1160931d","icon":"58389","name":"Voice training (12min)","description":"## CONDITIONS \n- All the process full focus\n\n## PROCESS \n- Day1: Pronunciation (12.5min)\n- Day2: Voice training (22min)","newHabit":"Show-up everyday","frequency":5,"weekdays":["WeekDay.tuesday","WeekDay.friday","WeekDay.wednesday","WeekDay.thursday","WeekDay.monday"],"validationType":"HabitType.simple","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":"19:30","additionalMetrics":[],"ponderation":1,"orderIndex":6,"color":4283215696,"frequencyChanges":{"2024-11-07T00:00:00.000":5,"2024-11-14T00:00:00.000":5,"2024-11-16T00:00:00.000":4,"2024-11-19T00:00:00.000":5,"2024-11-20T00:00:00.000":6,"2024-11-25T00:00:00.000":5},"synced":false,"duration":60},"schedule":{"scheduleId":"ef9c2652-cd68-4957-9e9b-f160d97113c9","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"3b938204-b552-49dc-8640-4ebe1160931d","startDate":"2025-01-06T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["friday","monday","wednesday"],"timesOfTheDay":["20:10","20:10","20:10","20:10","20:10","20:10","20:10"],"notification":[]},"validated":true},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"c3d99f59-5519-4033-af45-04c693850ea5","icon":"984669","name":"Sleep routine","description":"## CONDITION\n- Routine before 01h40\n\n## PROCESS\n- 22h40 - Daily recap\n- 23h00 - Stop working / No screen\n- /Food\n- /Cold shower ","newHabit":null,"frequency":6,"weekdays":["WeekDay.monday","WeekDay.wednesday","WeekDay.tuesday","WeekDay.thursday","WeekDay.sunday","WeekDay.saturday"],"validationType":"HabitType.simple","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":"21:40","additionalMetrics":["Sleep time"],"ponderation":2,"orderIndex":9,"color":4294951175,"frequencyChanges":{"2024-11-07T00:00:00.000":6},"synced":false,"duration":60},"schedule":{"scheduleId":"874fd472-ac4d-4a9f-a822-0b8d39f1d297","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"c3d99f59-5519-4033-af45-04c693850ea5","startDate":"2025-01-04T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["monday","wednesday","tuesday","thursday","sunday","friday","saturday"],"timesOfTheDay":[null,null,null,null,null,null,null],"notification":[10,0]},"validated":null},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"5cfa2dd6-5e43-446d-8209-5534a4e6fe3a","icon":"58595","name":"[ Health & Dopamine Protocol ]","description":"Screen:\n  - No phone and screen from 11pm-6am (Exept work to 12am)\n  - Try phone black and white from 11pm-4pm\n  - /Try phone shut down from 10pm-4pm if possible\n\nContent:\n  - No short content (No reels / No actuality feed) exept for work\n  - No video games \n  - No YouTube / expansion on phone (Exept)\n  - No Film / Series / Entertainment before 7pm\n  - No Social media / contact before 4pm OR before finishing work routine (Except SMS and call) \n  - No random expansion before 7pm\n  - Not work content only for decompression\n\nBed & Sex:\n  - Wake-up straight 6/7 days a week\n  - Not in bed before 7pm (Except 10-20min / 2h nap but in horizontal)\n  - No fap before 7pm\n  - Fap every 3 days maximum\n  - Sleep with women only Friday and Saturday\n\nIntoxication:\n  - No cheat food / Fast sugar before 7pm\n  - Cheat meal / Fast sugar only two time in a week\n  - No Tabaco / Alcool exept cheatD\n  - Tabaco allowed only one time a week\n  - Alcool allowed only one time a week\n  - Drugs only one time a month","newHabit":null,"frequency":5,"weekdays":["WeekDay.monday","WeekDay.tuesday","WeekDay.wednesday","WeekDay.friday","WeekDay.thursday"],"validationType":"HabitType.simple","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":null,"additionalMetrics":[],"ponderation":2,"orderIndex":10,"color":4284513675,"frequencyChanges":{"2024-11-07T00:00:00.000":6,"2024-11-11T00:00:00.000":7,"2024-11-17T00:00:00.000":6,"2024-11-25T00:00:00.000":5},"synced":false,"duration":60},"schedule":{"scheduleId":"72619e44-2b23-4a63-9397-623b3cacda22","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"5cfa2dd6-5e43-446d-8209-5534a4e6fe3a","startDate":"2024-12-16T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["monday","tuesday","wednesday","friday","thursday","saturday","sunday"],"timesOfTheDay":null,"notification":null},"validated":null},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"face51df-9287-4e63-ba42-7ed071c92356","icon":"58503","name":"[ Optimal interactions ]","description":"## CONDITIONS:\nOptimal interactions if interaction","newHabit":"Expansion: Each time you’re going out >20min (Gym, Meal, Party, Exploration). Speak to one unknown.","frequency":6,"weekdays":["WeekDay.sunday","WeekDay.monday","WeekDay.tuesday","WeekDay.wednesday","WeekDay.thursday","WeekDay.friday"],"validationType":"HabitType.recap","startDate":"2024-11-11T00:00:00.000","endDate":null,"timeOfTheDay":null,"additionalMetrics":[],"ponderation":3,"orderIndex":11,"color":4284513675,"frequencyChanges":{"2024-11-07T00:00:00.000":7,"2024-11-17T00:00:00.000":6},"synced":false,"duration":60},"schedule":{"scheduleId":"0b0dbbdb-cad6-4d47-af19-959c3f5a92ba","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"face51df-9287-4e63-ba42-7ed071c92356","startDate":"2024-12-16T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["sunday","monday","tuesday","wednesday","thursday","friday","saturday"],"timesOfTheDay":null,"notification":null},"validated":null},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"44b29bd4-4fe9-4508-9c2b-ba36faeeec41","icon":"58003","name":"[ Global efficiency ] ","description":"","newHabit":"- Schedule sequence: Respect the schedule and sequence whenever you wake-up","frequency":5,"weekdays":["WeekDay.tuesday","WeekDay.wednesday","WeekDay.thursday","WeekDay.friday","WeekDay.monday"],"validationType":"HabitType.recap","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":null,"additionalMetrics":["Quantity","Produced","Efficiency"],"ponderation":5,"orderIndex":12,"color":4284513675,"frequencyChanges":{"2024-11-07T00:00:00.000":7,"2024-11-08T00:00:00.000":6,"2024-11-12T00:00:00.000":5,"2024-11-14T00:00:00.000":6,"2024-11-25T00:00:00.000":5},"synced":false,"duration":60},"schedule":{"scheduleId":"1d28b4c6-7c04-42c3-8841-109ce9bf03b2","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"44b29bd4-4fe9-4508-9c2b-ba36faeeec41","startDate":"2024-12-16T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["tuesday","wednesday","thursday","friday","monday","saturday"],"timesOfTheDay":null,"notification":null},"validated":null},{"habit":{"userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"90a8134d-68aa-4053-863d-0208c92c557a","icon":"983909","name":"[ Journaling & Emotions ]","description":"## CONDITIONS \nRecap day consciously\n\n## PROCESS\n- Recap day\n   - General\n   - Activities\n   - Global field\n   - Emotions \n- Plan & Prepare the next day \n- Recall the recap\n- Recall goals / Improvements ","newHabit":"At least 6 produced ler day","frequency":6,"weekdays":["WeekDay.monday","WeekDay.tuesday","WeekDay.wednesday","WeekDay.thursday","WeekDay.friday","WeekDay.sunday"],"validationType":"HabitType.recapDay","startDate":"2024-11-04T00:00:00.000","endDate":null,"timeOfTheDay":null,"additionalMetrics":[],"ponderation":2,"orderIndex":13,"color":4284513675,"frequencyChanges":{"2024-11-07T00:00:00.000":7,"2024-11-17T00:00:00.000":6},"synced":false,"duration":60},"schedule":{"scheduleId":"3631cef4-27ad-4fcd-9ca1-ca11f9adb552","userId":"aDwFsI6ffBT16Ipb1yULVmWV5wy2","habitId":"90a8134d-68aa-4053-863d-0208c92c557a","startDate":"2024-12-16T00:00:00.000","endDate":null,"endingDate":null,"paused":false,"type":"Weekly","period1":1,"whenever":false,"period2":1,"daysOfTheWeek":["monday","tuesday","wednesday","thursday","friday","sunday","saturday"],"timesOfTheDay":null,"notification":null},"validated":null}]
            """
        
        
        let todayHabitsSchedule = parseHabitData(from: title) ?? []
        let displayManager = DisplayManager(
            todayHabitsSchedule: todayHabitsSchedule, nextOtherDayHabit: nil)
        displayManager.nextSchedule()
        displayManager.setCountDownTextDisplay()

        //      Get the data from the user defaults to display

        if displayManager.isStarted == nil || displayManager.isStarted == false {
            let entry = HomeWidgetEntry(
                date: Date(), heightRatio: 1.0, displayManager: displayManager
            )
            entries.append(entry)
        } else {
            let maxEntries = Int(abs(displayManager.dateTimeEnd?.timeIntervalSince(Date()) ?? 0.0))
            
            let maxList = [100, maxEntries].min()
            for i in 0...maxList! {
                // Determine widget refresh date & create an entry
                let components = DateComponents(second: i * 5)
                let refreshDate = Calendar.current.date(byAdding: components, to: Date())!

                // Determine
                let initialHeightRatio =
                    (displayManager.durationSinceStarted ?? 0.0)
                    / (displayManager.actualHabitSchedule?.habit.duration ?? DisplayManager.defaultDuration)

                let leftHeightRatio = (1.0 - initialHeightRatio) * Double((i / maxEntries))

                let heightRatio = initialHeightRatio + leftHeightRatio

                let entry = HomeWidgetEntry(
                    date: refreshDate, heightRatio: heightRatio, displayManager: displayManager
                )
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    
}
}

struct HomeWidgetView: View {
    var entry: Provider.Entry

    var body: some View {
        let displayManager = entry.displayManager
        let fillHeightRatio = entry.heightRatio
        let habitColor = displayManager.fillerColor
        let habitName = displayManager.habitName
        let habitIcon = displayManager.habitIcon
        let iconString = String(Character(UnicodeScalar(habitIcon)!))
        

        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {

                Rectangle()
                    .frame(width: geometry.size.width + 36, height: geometry.size.height + 36)
                    .foregroundColor(Color(habitColor)).position(
                        x: geometry.size.width / 2,
                        y: ((geometry.size.height / 2 ) - ((geometry.size.height + 36) * (1 - fillHeightRatio))))

                Rectangle()
                    .frame(width: geometry.size.width + 36, height: geometry.size.height + 36)
                    .foregroundColor(Color(habitColor).opacity(0.45)).position(
                        x: geometry.size.width / 2, y: geometry.size.height / 2)

    
                
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        
                        
                        Text(iconString) // Unicode for "add" symbol
                            .font(.custom("MaterialIcons-Regular", size: 40)).foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 6)

                    HStack {

                        Text(displayManager.textCountDown)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        if displayManager.countDownData != nil {
                            Text(displayManager.countDownData!, style: .timer)
                                .monospacedDigit()
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                        }
                    }

                    Text(habitName)
                        .foregroundColor(.white)
                        .font(.title3).bold()
                        .lineLimit(1)
                        .truncationMode(.tail)

                }.padding(.bottom, 16)
                    .widgetBackground(Color.white)
            }
        }
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

struct home_widget_test: Widget {
    let kind: String = "home_widget_test"

    var body: some WidgetConfiguration {
        // Use StaticConfiguration for TimelineProvider without user input
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HomeWidgetView(entry: entry)
        }
        .configurationDisplayName("Home Widget")
        .description("This is a widget to display the next habit.")
    }
}

struct home_widget_test_Previews: PreviewProvider {
    static var previews: some View {
        // Create dummy habits and schedules for preview

        // Create a DisplayManager instance with the above schedule
        let displayManager = DisplayManager(
            todayHabitsSchedule: [], nextOtherDayHabit: nil)

        // Create a HomeWidgetEntry with the displayManager
        let entry = HomeWidgetEntry(
            date: Date(), heightRatio: 1.0, displayManager: displayManager)

        // Return the preview view with the entry
        HomeWidgetView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
