//
//  HeaderView.swift
//  Purs.iOS
//
//  Created by Artem Mkrtchyan on 1/9/24.
//

import SwiftUI

struct HeaderView: View {
    var headerText:String
    var pointColor: Color
    @Binding var isHidden: Bool
    
    var body: some View {
        HStack(alignment: .center, content: {
            
            VStack(alignment: .leading) {
                HStack(spacing: 7){
                    Text(headerText)
                        .font(Font.custom("Hind Siliguri", size: 16))
                        .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 7)
                        .foregroundColor(pointColor)
                }
                Spacer()
                Button(action: {
                    withAnimation{
                        isHidden.toggle()
                    }
                }, label: {
                    Text(isHidden ? "CLOSE SCHEDULE" : "SEE FULL HOURS")
                        .font(Font.custom("Chivo", size: 12))
                        .foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20).opacity(0.31))
                })
                .frame(alignment: .leading)
            }
            .padding(.vertical, 15)
            Spacer()
            Button(action: {
                withAnimation{
                    isHidden.toggle()
                }
            }, label: {
                Image(systemName: withAnimation{ isHidden ? "chevron.right" : "chevron.up"})
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.black)
            })
            .frame(width: 24, height: 24)
            
        }
        )
        .frame(height: 81, alignment: Alignment.leading)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 0)
        .padding(.vertical, 0)
    }
}


#Preview{
    HeaderView(headerText: "Open until 7 PM, reopens at 9 AM", pointColor: .green, isHidden: .constant(true))
}
