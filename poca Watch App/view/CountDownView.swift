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
    @State var opacity3:Double = 1
    
    @State var scale2:Double = 1
    @State var opacity2:Double = 1
    
    @State var scale1:Double = 1
    @State var opacity1:Double = 1
    
    var body: some View {
        ZStack {
            Text("1")
                .font(.system(size: 112, weight: .bold, design: .rounded)
                )
                .padding(.bottom, 24)
                .background(.black)
                .scaleEffect(scale1)
                .opacity(opacity1)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1).delay(2)) {
                        scale1 = 1.5
                    }
                }
                .onAppear {
                    withAnimation(Animation.linear(duration: 0.3).delay(2.7)) {
                        opacity1 = 0
                    }
                }
            Text("2")
                .font(.system(size: 112, weight: .bold, design: .rounded)
                )
                .padding(.bottom, 24)
                .background(.black)
                .scaleEffect(scale2)
                .opacity(opacity2)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1).delay(1)) {
                        scale2 = 1.5
                    }
                }
                .onAppear {
                    withAnimation(Animation.linear(duration: 0.3).delay(1.7)) {
                        opacity2 = 0
                    }
                }
            Text("3")
                .font(.system(size: 112, weight: .bold, design: .rounded)
                )
                .padding(.bottom, 24)
                .background(.black)
                .scaleEffect(scale3)
                .opacity(opacity3)
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1)) {
                        scale3 = 1.5
                    }
                }
                .onAppear {
                    withAnimation(Animation.linear(duration: 0.3).delay(0.7)) {
                        opacity3 = 0
                    }
                }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(1))
                WKInterfaceDevice.current().play(.start)
                try? await Task.sleep(for: .seconds(1))
                WKInterfaceDevice.current().play(.start)
                try? await Task.sleep(for: .seconds(1))
                WKInterfaceDevice.current().play(.success)
            }
        }
    }
}

#Preview {
    CountDownView()
}
