//
//  SwiftUIView.swift
//  
//
//  Created by Nazar Tsok on 18.01.2024.
//

import SwiftUI

struct TEST2: View {
    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    

                Text("2")
                    .font(.system(size: 56))
                    .fontWeight(.bold)

                Text("mins")
                    .font(.body)
            }
            .background(Color.yellow)
       
        HStack(alignment: .lastTextBaseline){
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 24, height: 24)
            
            Text("mins")
                .font(.body)
           
        }
        .background(Color.green)
    }
    }
}

#Preview {
    TEST2()
}

//
//  File.swift
//
//
//  Created by Nazar Tsok on 18.01.2024.
//

import Foundation
import SwiftUI

public extension LabelStyle where Self == PremiumLabelStyle {
    static var premiumTag: PremiumLabelStyle {
        PremiumLabelStyle()
    }
}

public struct PremiumLabelStyle: LabelStyle {
    
   public func makeBody(configuration: Configuration) -> some View {
       HStack(alignment : .lastTextBaseline, spacing: 3) {
            configuration.icon
               .frame(width: 10, height: 10)
            configuration.title
        }
//        .font(.caption)
        .foregroundStyle(Color.red)
    }
}
