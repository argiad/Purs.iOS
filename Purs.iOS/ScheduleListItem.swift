//
//  ScheduleListItem.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import SwiftUI

struct ScheduleListItem:View {
    let key: DayOfWeek
    let value:[[Date]]
    
    
    var body: some View {
        
        HStack(alignment:.top ){
            Text("\(key.fullName)")
            
//                .font(Font.custom("Hind Siliguri", size: 16)) // have no time to search and add necessary weights
                .font(Font.custom("Arial", size: 16))
                .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                .frame(alignment: .topLeading)
                .fontWeight(key.isToday() ? .bold : .regular)
            Spacer()
                .frame(maxWidth: .infinity)
            LazyVStack(alignment:.trailing) {
                ForEach(value, id: \.self ){ timePeriod in
                    Text( is24Open(timePeriod) ? "Open 24hrs" : "\(format( timePeriod.first))-\(format( timePeriod.last))")
//                        .font(Font.custom("Hind Siliguri", size: 16)) // have no time to search and add necessary font's weights
                        .font(Font.custom("Arial", size: 16))
                        .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                        .lineLimit(1)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: true, vertical: false)
                        .fontWeight(key.isToday() ? .bold : .regular)
                    
                }
            }
            .frame(alignment: .trailing)
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: height())
    }
    
    private func is24Open(_ period: [Date])-> Bool {
        if let hours = Calendar.current.dateComponents([.hour], from: period.first!, to: period.last!).hour {
            return hours == 24
        }
     return false
    }
    
    private func height() -> CGFloat {
        return CGFloat(value.count) * 24
    }
    
    private func format(_ date: Date?) -> String {
        let encoderDateFormatter = DateFormatter()
        encoderDateFormatter.dateFormat = "hh:mma"
        encoderDateFormatter.isLenient = true
        encoderDateFormatter.timeZone = .gmt
        return encoderDateFormatter.string(from: date!)
    }
}
