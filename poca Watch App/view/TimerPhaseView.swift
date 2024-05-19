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
    
    @StateObject var timerManager = TimerManager()
    @Binding var stepPomodoro:Int
    
//    @State private var timeRemaining:TimeInterval = 0
//    @State private var timer:Timer?
//    @State private var startTheTimer:Int = 1
    
    @State private var activeAlert: ActiveAlert?
    @State private var isAlertPresented = false
    
    @State var orcaOffset2:CGSize = CGSize(width: 0, height: 200)
    
    let durationWork:Double = 1500
    let durationRest:Double = 300
    
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
                if timerManager.timerPhase == 1 && stepPomodoro > 0 {
                    CountDownView()
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(3))
                                timerManager.timerPhase = 2
                            }
                        }
                } else if timerManager.timerPhase == 2 {
                    Circle()
                        .stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: CGFloat(20), lineCap: .round, lineJoin: .round))
                        .background(Color.clear)
                        .rotationEffect(Angle(degrees: -90))
                    Circle()
                        .trim(from: 0, to: stepPomodoro % 2 == 1 ?
                              CGFloat (timerManager.remainingTime / durationWork)
                              :
                                CGFloat (timerManager.remainingTime / durationRest)
                        )
                        .stroke(stepPomodoro % 2 == 1 ? .blue30 : .green30, style: StrokeStyle(lineWidth: CGFloat(20), lineCap: .round, lineJoin: .round))
                        .background(Color.clear)
                        .shadow(color: stepPomodoro % 2 == 1 ? .blueBase : .greenBase,radius: 10)
                        .rotationEffect(Angle(degrees: -90))
                        .onAppear {
                            Task {
                                startTimer()
                            }
                        }
                    VStack {
                        Text(timerManager.timeString)
                            .font(.system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundColor(stepPomodoro % 2 == 1 ? .blue30 : .green30)
                        Text(stepPomodoro % 2 == 1 ? "focus" : "rest")
                            .foregroundColor(.gray)
                    }
                } else if timerManager.timerPhase == 3 {
                    VStack {
                        Text(stepPomodoro % 2 == 1 ? "REST\nTIME!" : "FOCUS\nTIME!")
                            .font(.system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundColor(stepPomodoro % 2 == 1 ? .green30 : .blue30)
                            .shadow(color: stepPomodoro % 2 == 1 ? .greenBase : .blueBase, radius: 10)
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
                            Button {
                                stopPomodoro()
                            } label: {
                                Image(systemName: "xmark")
                                .padding()
                            }
                            .buttonStyle(GreyButtonStyle())
                            Button {
                                nextPhase()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(stepPomodoro % 2 == 1 ? "REST" : "FOCUS")
                                        .font(.system(.headline, design: .rounded))
                                        .foregroundColor(stepPomodoro % 2 == 1 ? .green30 : .blue30)
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
                    secondaryButton: .default(Text(stepPomodoro % 2 == 1 ? "REST" : "FOCUS"), action: {
                        skipAPhase()
                    })
                )
            case .none:
                return Alert(title: Text("Unknown Alert"))
            }
        })
        .onAppear {
            timerManager.timerPhase = 1
        }
    }
    
    private func startTimer() {
        Task {
            timerManager.remainingTime = 0
            try? await Task.sleep(nanoseconds: 1)
            // do animation
            withAnimation(Animation.spring(duration:1), {
                if stepPomodoro % 2 == 1 {
                    timerManager.remainingTime = TimeInterval(durationWork)
                } else {
                    timerManager.remainingTime = TimeInterval(durationRest)
                }
            })
        }
        
            
        // set timer manager
        if stepPomodoro % 2 == 1 {
            timerManager.start(duration: TimeInterval(durationWork))
        } else {
            timerManager.start(duration: TimeInterval(durationRest))
        }
    }
    
    private func stopTimer() {
        timerManager.stop()
    }
    
    private func nextPhase() {
        // notify using haptic
        WKInterfaceDevice.current().play(.directionUp)
        
        withAnimation(Animation.spring(duration: 1)) {
            timerManager.orcaOffset = CGSize(width: 0, height: 200)
        }
        
        // stop and arange data
        stopTimer()
        stepPomodoro += 1
        if stepPomodoro % 2 == 1 {
            timerManager.timerPhase = 1
            timerManager.duration = TimeInterval(durationWork)
        } else {
            timerManager.timerPhase = 2
            timerManager.duration = TimeInterval(durationRest)
        }
    }
    
    private func skipAPhase() {
        // notify using haptic
        WKInterfaceDevice.current().play(.directionUp)
        
        // stop and arange data
        stopTimer()
        timerManager.timerPhase = 3
        withAnimation(Animation.spring(duration: 1)) {
            timerManager.orcaOffset = CGSize(width: 0, height: 26)
        }
//        stepPomodoro += 1
//        if stepPomodoro % 2 == 1 {
//            timerManager.timerPhase = 1
//        } else {
//            timerManager.timerPhase = 2
//            timerManager.start(duration: TimeInterval(durationRest))
//        }
    }
    
    private func stopPomodoro() {
        // notify using haptic
        WKInterfaceDevice.current().play(.failure)
        
        // stop and arange data
        stopTimer()
        stepPomodoro = 0
        timerManager.timerPhase = 0
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var stepPomodoro:Int = 1
        var body: some View {
            TimerPhaseView(stepPomodoro: $stepPomodoro)
        }
    }
    return PreviewWrapper()
}
