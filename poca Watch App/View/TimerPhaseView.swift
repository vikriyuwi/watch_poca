//
//  TimerPhaseView.swift
//  poca Watch App
//
//  Created by win win on 17/05/24.
//

import SwiftUI

enum ActiveAlert {
    case stopPomodoro, nextPomodoro
}

struct TimerPhaseView: View {
    
    @ObservedObject var timerManager:TimerManager
    
    @State private var activeAlert: ActiveAlert?
    @State private var isAlertPresented = false
    
    let pomodoroRound = UserDefaults.standard.integer(forKey: "pomodoroRound")
    
    var body: some View {
        NavigationStack {
            ZStack{
                VStack {
                    Spacer()
                    Image("OrcaTummy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: .infinity)
                        .offset(timerManager.orcaOffset)
                }
                .ignoresSafeArea()
                if timerManager.timerPhase == 1 && timerManager.stepPomodoro > 0 {
                    CountDownView()
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(3))
                                timerManager.timerPhase = 2
                            }
                        }
                } else if timerManager.timerPhase == 2 {
                    // background circle
                    Circle()
                        .stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: CGFloat(20), lineCap: .round, lineJoin: .round))
                        .background(Color.clear)
                        .rotationEffect(Angle(degrees: -90))
                    
                    // foreground circle (progress
                    Circle()
                        .trim(from: 0, to: timerManager.stepPomodoro % 2 == 1 ?
                              CGFloat (timerManager.remainingTime / timerManager.durationWork)
                              :
                                CGFloat (timerManager.remainingTime / timerManager.durationRest)
                        )
                        .stroke(timerManager.stepPomodoro % 2 == 1 ? .blue30 : .green30, style: StrokeStyle(lineWidth: CGFloat(20), lineCap: .round, lineJoin: .round))
                        .background(Color.clear)
                        .shadow(color: timerManager.stepPomodoro % 2 == 1 ? .blueBase : .greenBase,radius: 10)
                        .rotationEffect(Angle(degrees: -90))
                    
                    // timer detail
                    VStack {
                        Text(timerManager.timeString)
                            .font(.system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundColor(timerManager.stepPomodoro % 2 == 1 ? .blue30 : .green30)
                        Text(timerManager.stepPomodoro % 2 == 1 ? "focus" : "rest")
                            .foregroundColor(.gray)
                    }
                    .onAppear {
                        Task {
                            timerManager.startPomodoro()
                        }
                    }
                } else if timerManager.timerPhase == 3 {
                    VStack {
                        Text(isLastStep() ? "IT'S A WRAP" : timerManager.stepPomodoro % 2 == 1 ? "REST\nTIME!" : "FOCUS\nTIME!")
                            .font(.system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundColor(timerManager.stepPomodoro % 2 == 1 ? .green30 : .blue30)
                            .shadow(color: timerManager.stepPomodoro % 2 == 1 ? .greenBase : .blueBase, radius: 10)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(10)
                }
            }
            .toolbar {
                if timerManager.timerPhase == 2 {
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                isAlertPresented = true
                                activeAlert = .stopPomodoro
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            Button {
                                WKInterfaceDevice.current().play(.click)
                                isAlertPresented = true
                                activeAlert = .nextPomodoro
                            } label: {
                                Image(systemName: "chevron.forward.2")
                                    .foregroundColor(.greenBase)
                            }
                        }
                    }
                } else if timerManager.timerPhase == 3 {
                    ToolbarItem(placement:.bottomBar) {
                        HStack {
                            if !isLastStep() {
                                Button {
                                    stopPomodoro()
                                } label: {
                                    Image(systemName: "xmark")
                                    .padding()
                                }
                                .buttonStyle(GreyButtonStyle())
                            }
                            Button {
                                isLastStep() ? stopPomodoro() : startNextPhase()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(isLastStep() ? "FINISH" : timerManager.stepPomodoro % 2 == 1 ? "REST" : "FOCUS")
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(timerManager.stepPomodoro % 2 == 1 ? .green30 : .blue30)
                                    Spacer()
                                }
                                .padding()
                            }
                            .buttonStyle(DarkButtonStyle())
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .alert(isPresented: $isAlertPresented, content: {
            switch activeAlert {
            case .stopPomodoro:
                return Alert(
                    title: Text("End Pomodoro?"),
                    primaryButton: .cancel(Text("CANCEL")),
                    secondaryButton: .default(Text("END"), action: {
                        stopPomodoro()
                    })
                )
            case .nextPomodoro:
                return Alert(
                    title: Text("Skip step?"),
                    primaryButton: .cancel(Text("CANCEL")),
                    secondaryButton: .default(
                        Text(timerManager.stepPomodoro % 2 == 1 ? "REST" : "FOCUS"),
                        action: {
                        skipPhase()
                    })
                )
            case .none:
                return Alert(title: Text("Unknown Alert"))
            }
        })
    }
    
    private func startNextPhase() {
        // notify using haptic
        WKInterfaceDevice.current().play(.directionUp)
        
        timerManager.nextPomodoro()
    }
    
    private func skipPhase() {
        // notify using haptic
        WKInterfaceDevice.current().play(.directionUp)
        
        timerManager.skipPhase()
    }
    
    private func stopPomodoro() {
        // notify using haptic
        WKInterfaceDevice.current().play(.failure)
        
        timerManager.stopPomodoro()
    }
    
    private func isLastStep() -> Bool {
        if pomodoroRound == timerManager.stepPomodoro / 2 {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @StateObject var timerManager = TimerManager()
        @State var stepPomodoro:Int = 1
        
        var body: some View {
            TimerPhaseView(timerManager: timerManager)
                .onAppear {
                    timerManager.timerPhase = 1
                    timerManager.stepPomodoro = 1
                }
        }
    }
    return PreviewWrapper()
}
