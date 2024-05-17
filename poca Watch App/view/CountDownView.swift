//
//  CountDownView.swift
//  poca Watch App
//
//  Created by win win on 17/05/24.
//

import SwiftUI

struct RoundedFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded))
    }
}

extension View {
    func roundedFont() -> some View {
        self.modifier(RoundedFontModifier())
    }
}

struct CountDownView: View {
    @State var scale3:Double = 1
    @State var opacity3:Double = 0
    
    @State var scale2:Double = 1
    @State var opacity2:Double = 0
    
    @State var scale1:Double = 1
    @State var opacity1:Double = 0
    
    var body: some View {
        ZStack {
            VStack {
                Text("1")
                    .font(.system(size: 112, weight: .bold, design: .rounded)
                    )
                    .scaleEffect(scale1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(opacity1)
            VStack {
                Spacer()
                Text("2")
                    .font(.system(size: 112, weight: .bold, design: .rounded)
                    )
                    .scaleEffect(scale2)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(opacity2)
            VStack {
                Spacer()
                Text("3")
                    .font(.system(size: 112, weight: .bold, design: .rounded)
                    )
                    .scaleEffect(scale3)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(opacity3)
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                // 3
                withAnimation(Animation.linear(duration: 0.2)) {
                    opacity3 = 1
                }
                withAnimation(Animation.easeOut(duration: 1)) {
                    scale3 = 1.5
                }
                try? await Task.sleep(for: .seconds(1))
                
                // 2
                withAnimation(Animation.linear(duration: 0.2)) {
                    opacity3 = 0
                    opacity2 = 1
                }
                withAnimation(Animation.easeOut(duration: 1)) {
                    scale2 = 1.5
                }
                WKInterfaceDevice.current().play(.start)
                try? await Task.sleep(for: .seconds(1))
                
                // 1
                withAnimation(Animation.linear(duration: 0.2)) {
                    opacity2 = 0
                    opacity1 = 1
                }
                withAnimation(Animation.easeOut(duration: 1)) {
                    scale1 = 1.5
                }
                WKInterfaceDevice.current().play(.start)
                try? await Task.sleep(for: .seconds(1))
                
                // 0
                withAnimation(Animation.linear(duration: 0.2)) {
                    opacity1 = 0
                }
                WKInterfaceDevice.current().play(.success)
            }
        }
    }
}

#Preview {
    CountDownView()
}
