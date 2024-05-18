//
//  LandingView.swift
//  poca Watch App
//
//  Created by win win on 17/05/24.
//

import SwiftUI
import WatchKit

struct LandingView: View {
    @State var breathScale:Double = 0.9
    @State var stepPomodoro:Int = 0
    
    @State var orcaOffset:CGSize = CGSize(width: 0, height: 200)
    
    var body: some View {
        NavigationStack {
            ZStack {
                if stepPomodoro < 1 {
                    VStack {
                        Spacer()
                        Image("OrcaTummy")
                            .resizable()
                            .scaledToFit()
                            .offset(orcaOffset)
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    VStack {
                        Spacer()
                        Image("PlaySymbol")
                            .foregroundColor(.white)
                            .frame(width: 92, height: 92)
                            .background(
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .scaleEffect(breathScale)
                            )
                            .scaleEffect(breathScale)
                            .offset(y: -24)
                            .onAppear {
                                let baseAnimation = Animation.easeOut(duration: 2)
                                let repeated = baseAnimation.repeatForever(autoreverses: true)
                                withAnimation(repeated) {
                                    breathScale = 1
                                }
                            }
                            .onTapGesture {
                                Task {
                                    withAnimation(Animation.spring(duration: 1), {
                                        orcaOffset = CGSize(width: 0, height: 200)
                                    })
                                    WKInterfaceDevice.current().play(.success)
                                    try? await Task.sleep(for: .seconds(1))
                                    stepPomodoro = 1
                                    WKInterfaceDevice.current().play(.start)
                                }
                            }
                        Spacer()
                    }
                    .onAppear {
                        withAnimation(Animation.spring(duration: 1), {
                            orcaOffset = CGSize(width: 0, height: 26)
                        })
                    }
                } else {
                    TimerPhaseView(stepPomodoro: $stepPomodoro)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    LandingView()
}
