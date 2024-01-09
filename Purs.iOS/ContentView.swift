//
//  ContentView.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var schedule: [LocationSchedule]
    
    @State private var isHidden: Bool = false
    
    var body: some View {
        ZStack{
            VStack {
                Text("\(schedule.first?.name ?? "")")
                    .font(Font.custom("Fira Sans", size: 54).weight(.black)) //TODO: need to add the font to the app
                    .foregroundColor(.white)
                
                
                LazyVStack(spacing: 0) {
                    
                    Section(
                        content: {
                            if (!isHidden){
                                if schedule.first != nil {
                                    ForEach ((schedule.first?.hours.sorted(by: { $0.key.ordinal() < $1.key.ordinal()}))!, id: \.key) { key, value in
                                        if isWorkingHours((key, value)) {
                                            let _ = minsUntilClosing(value)
                                        }
                                        ScheduleListItem(key: key, value: value)
                                    }
                                    .background(.clear)
                                }
                            }
                        },
                        header: {
                            HeaderView(headerText: getHeaderStateText(), pointColor: getMarkerColor(), isHidden: $isHidden)
                            if (!isHidden){
                                Rectangle()
                                    .frame(alignment: .bottom)
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 0.5)
                                    .background(.black.opacity(0.25))
                                    .padding(.horizontal, 18)
                            }
                            
                        } )
                    .padding([.leading, .trailing], 21)
                }
                .frame(height:  81 + (isHidden ? 0 : calculateHeight()))
                .background(Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0.60))
                .cornerRadius(8)
                .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 10.20, y: 4
                )
                .scrollContentBackground(.hidden)
                .padding([.leading, .trailing], 21)
                
                
                Spacer()
                
            }
            VStack {
                Spacer()
                Button(action: {
                    print("Show menu")
                }, label: {
                    VStack(spacing: 2){
                        Image(systemName: "chevron.up")
                            .frame(width: 12, height: 12)
                            .foregroundColor(.white.opacity(0.5))
                        Image(systemName: "chevron.up")
                            .frame(width: 12, height: 12)
                            .foregroundColor(.white)
                        Text("View Menu")
                            .font(Font.custom("Hind Siliguri", size: 24)) // Need font
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(width: 163, height: 58, alignment: .top)
                    }
                    .frame( maxWidth: .infinity )
                })
            }
        }
        .background(
            AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/p/AF1QipNvaaR6eoBC7I48N_-ROU30qsi_h2Sf5eQRxWtr=s1360-w1360-h1020"))
        )
        .onAppear{
            Task {
                if let response = try? await networkActor.getData(useDataDump: false){
                    process(response: response)
                }
            }
        }
        
    }
    
    
    // Business logic
    // TODO: Extract to dedicted Class
    private func getMarkerColor() -> Color{
        if let daySchedule = schedule.first?.hours.first(where: { $0.key.isToday()}) {
            
            if let positiveMin = minsUntilClosing(daySchedule.value).first(where: { $0 > 0 }) {
                return positiveMin > 60 ? .green : .orange
            } else {
                return .red
            }
            
        } else {
            return .red
        }
    }
    
    private func getTime() -> Date {
        
        let encoderDateFormatter = DateFormatter()
        encoderDateFormatter.dateFormat = "HH:mm:ss"
        encoderDateFormatter.isLenient = true
        encoderDateFormatter.timeZone = .current
        
        let decoderDateFormatter = DateFormatter()
        decoderDateFormatter.dateFormat = "HH:mm:ss"
        decoderDateFormatter.isLenient = true
        decoderDateFormatter.timeZone = .gmt
        
        return decoderDateFormatter.date(from: (encoderDateFormatter.string(from: Date.now)))!
    }
    
    private func minsUntilClosing(_ time:[[Date]]) -> [Int] {
        // TODO: need to test all cases !!!!
        
        let result = time.map{ isInRange($0) ?  Calendar.current.dateComponents([.minute], from: getTime(), to: $0.last!).minute! :
            Calendar.current.dateComponents([.minute], from: max ($0.first!,getTime()) , to:min($0.first!,getTime()) ).minute!}
        
        return result
    }
    
    private func isInRange(_ date: [Date]) -> Bool {
        // 24 hours / whole day
        if date.first!.timeIntervalSince1970 == date.last!.timeIntervalSince1970 {
            return true
        }
        
        let timeNow = getTime()
        
        let result = DateInterval(start: date.first!, end: date.last!).contains(timeNow)
        return result
    }
    
    private func isWorkingHours(_ daySchedule: (DayOfWeek,[[Date]])) -> Bool {
        if (!daySchedule.0.isToday()){
            return false
        }
        return daySchedule.1.map{ isInRange($0)}.contains(true)
    }
    
    
    private func getHeaderStateText() -> String {
        let decoderDateFormatter = DateFormatter()
        decoderDateFormatter.dateFormat = "hh:mm a"
        decoderDateFormatter.isLenient = true
        decoderDateFormatter.timeZone = .current
        
        
        
        if let scheduledDay = schedule.first?.hours.first(where: {$0.key.isToday()}) {
            let mins = minsUntilClosing(scheduledDay.value).max() ?? -1
            let calendar = Calendar.current
            
            
            switch mins {
            case 60..<Int.max :
                let newDate = calendar.date(byAdding: .minute, value: mins + 1, to: Date.now)!
                return "Open until \(decoderDateFormatter.string(from: newDate))"
            case 0...60:
                let newDate = calendar.date(byAdding: .minute, value: mins, to: Date.now)!
                
                var reopens: String = "{REOPENS}"
                
                if let firstPositiveIndex = minsUntilClosing(scheduledDay.value).firstIndex(where: {$0 > 0 && $0 > 60}) {
                    let actingPeriod = scheduledDay.value[firstPositiveIndex]
                    reopens = "reopens at" + decoderDateFormatter.string(from: findNextTimePeriod(after: actingPeriod).0.first!)
                } else {
                    let nextPeriod = findNextTimePeriod(after: scheduledDay.value.last!)
                    reopens = "reopens at " + decoderDateFormatter.string(from: nextPeriod.0.first!)
                }
                
                return "Open until \(decoderDateFormatter.string(from: newDate)),  \(reopens)"
            case (-24*60)...0:
                // find next period
                let nextPeriod = findNextTimePeriod(after: scheduledDay.value.last!)
                decoderDateFormatter.timeZone = .gmt
                return "Opens again at \(decoderDateFormatter.string(from: nextPeriod.0.first!))"
            default:
                let nextPeriod = findNextTimePeriod(after: scheduledDay.value.last!)
                return "Opens \(nextPeriod.1.fullName) " + decoderDateFormatter.string(from: nextPeriod.0.first!)
            }
        }
        
        return "Something went wrong"
    }
    
    private func findNextTimePeriod(after: [Date]) ->([Date],DayOfWeek){
        let index = DayOfWeek.allCases.firstIndex(where: { $0.isToday()})!
        let tail = DayOfWeek.allCases[(index)..<DayOfWeek.allCases.count]
        let head = DayOfWeek.allCases[0..<index]
        
        
        for weekday in (tail + head){
            if let period = schedule.first?.hours[weekday]?.first( where: { !isWorkingHours(( weekday, [$0])) }) {
                return (period, weekday)
            }
        }
        
        // if did not find any
        return (after, DayOfWeek.allCases.first(where: {$0.isToday()})!)
    }
    
    
    private func calculateHeight() -> CGFloat {
        return  CGFloat( (schedule.first?.hours.reduce(0, { (s, i) in return s + i.value.count  }) ?? 0)) * 24
    }
    
    
    private func process(response: LocationItemResponse) {
        do {
            try modelContext.delete(model: LocationSchedule.self)
            try modelContext.save()
            
            let grouped: Dictionary<DayOfWeek, Array<[Date]>>  =
            Dictionary(grouping: response.hours, by: { $0.day })
                .sorted{ $0.key.ordinal() < $1.key.ordinal()}
                .reduce([DayOfWeek: Array<[Date]>]()){ (dict, obj) in
                    var dict = dict
                    dict[obj.key] = obj.value.map{ [$0.start, $0.end]}
                    return dict
                }
            
            
            let schedule = LocationSchedule(name: response.name, workingHours: grouped)
            withAnimation{
                modelContext.insert(schedule)
            }
            
        } catch {
            print("Data processing error")
        }
    }
}


//
//#Preview {
//    ContentView()
//        .modelContainer(for: LocationSchedule.self, inMemory: true)
//}
