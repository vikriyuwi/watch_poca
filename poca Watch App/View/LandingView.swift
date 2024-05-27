//
//  LandingView.swift
//  poca Watch App
//
//  Created by win win on 17/05/24.
//

import SwiftUI
import WatchKit

struct LandingView: View {
    @StateObject var timerManager = TimerManager()
    
    @State private var breathScale:Double = 0.9
    
    @State private var pomodoroRound = UserDefaults.standard.integer(forKey: "pomodoroRound")
    
    let pomodoroRoundNumbers = Array(1...9)
    
    var body: some View {
        NavigationStack {
            ZStack {
                if timerManager.stepPomodoro < 1 {
                    VStack {
                        Spacer()
                        Image("OrcaTummy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: .infinity)
                            .offset(timerManager.orcaOffset)
                    }
                    .ignoresSafeArea()
                    VStack {
                        Text("Select rounds")
                            .font(.headline)
                        Picker("", selection: $pomodoroRound) {
                            ForEach(pomodoroRoundNumbers, id: \.self) { number in
                                Text("\(number)")
                                    .tag(number)
                                    .font(number == pomodoroRound ? .title2 : .body)
                                    .bold(number == pomodoroRound ? true : false)
                            }
                        }
                        .focusBorderColor(color: .white)
                        .labelsHidden()
                        .frame(height: 72)
                        Button {
                            UserDefaults.standard.set(pomodoroRound, forKey: "pomodoroRound")
                            Task {
                                timerManager.timerPhase = 1
                                timerManager.stepPomodoro = 1
                                // play haptic
                                WKInterfaceDevice.current().play(.start)
                            }
                        } label: {
                            HStack {
                                Text("START")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding(.top, 10)
                        .buttonStyle(LightButtonStyle())
                    }
                    .padding()
                } else {
                    TimerPhaseView(timerManager:timerManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    LandingView()
}
