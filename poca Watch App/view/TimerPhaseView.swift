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
    @Binding var stepPomodoro:Int
    
    @State private var timeRemaining:TimeInterval = 0
    @State private var timer:Timer?
    @State private var startTheTimer:Int = 1
    
    @State private var activeAlert: ActiveAlert?
    @State private var isAlertPresented = false
    
    @State var orcaOffset2:CGSize = CGSize(width: 0, height: 200)
    
    var body: some View {
        NavigationStack {
            ZStack{
                VStack {
                    Spacer()
                    Image("OrcaTummy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: .infinity)
                        .offset(orcaOffset2)
                }
                .ignoresSafeArea()
                if startTheTimer == 1 && stepPomodoro > 0 {
                    CountDownView()
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(3))
                                startTheTimer = 2
                            }
                        }
                } else if startTheTimer == 2 {
                    Circle()
                        .stroke(.white.opacity(0.1), style: StrokeStyle(lineWidth: CGFloat(20), lineCap: .round, lineJoin: .round))
                        .background(Color.clear)
                        .rotationEffect(Angle(degrees: -90))
                    Circle()
                        .trim(from: 0, to: stepPomodoro % 2 == 1 ? CGFloat(1 - (timeRemaining / 1500)) : CGFloat(1 - (timeRemaining / 300)))
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
                        Text(formatedTime())
                            .font(.system(
                                size: 30,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundColor(stepPomodoro % 2 == 1 ? .blue30 : .green30)
                        Text(stepPomodoro % 2 == 1 ? "do work" : "do rest")
                            .foregroundColor(.gray)
                    }
                } else if startTheTimer == 3 {
                    VStack {
                        Text(stepPomodoro % 2 == 1 ? "REST\nTIME!" : "WORK\nTIME!")
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
                if startTheTimer == 2 {
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
                                Image(systemName: "checkmark")
                                    .foregroundColor(.greenBase)
                            }
                        }
                    }
                } else if startTheTimer == 3 {
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
                                nextPomodoro()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(stepPomodoro % 2 == 1 ? "REST" : "WORK")
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
                    secondaryButton: .default(Text(stepPomodoro % 2 == 1 ? "REST" : "WORK"), action: {
                        skipPomodoro()
                    })
                )
            case .none:
                return Alert(title: Text("Unknown Alert"))
            }
        })
    }
    
    private func formatedTime() -> String {
        let minute = Int(timeRemaining) / 60
        let second = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minute, second)
    }
    
    private func startTimer() {
        withAnimation(Animation.spring(duration:1), {
            if stepPomodoro % 2 == 1 {
                timeRemaining = 1499
            } else {
                timeRemaining = 299
            }
        })
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                timer = nil
                WKInterfaceDevice.current().play(.success)
                startTheTimer = 3
                withAnimation(Animation.spring(duration:1), {
                    orcaOffset2 = CGSize(width: 0, height: 26)
                })
            }
        }
    }
    
    private func skipPomodoro() {
        timer?.invalidate()
        timer = nil
        WKInterfaceDevice.current().play(.success)
        startTheTimer = 3
        withAnimation(Animation.spring(duration:1), {
            orcaOffset2 = CGSize(width: 0, height: 26)
        })
        timeRemaining = 0
    }
    
    private func nextPomodoro() {
        timer?.invalidate()
        timer = nil
        WKInterfaceDevice.current().play(.directionUp)
        if stepPomodoro % 2 == 1 {
            startTheTimer = 2
            timeRemaining = 300
        } else {
            startTheTimer = 1
            timeRemaining = 1500
        }
        stepPomodoro += 1
        withAnimation(Animation.spring(duration:1), {
            orcaOffset2 = CGSize(width: 0, height: 200)
        })
        timeRemaining = 0
    }
    
    private func stopPomodoro() {
        WKInterfaceDevice.current().play(.failure)
        timer?.invalidate()
        timer = nil
        stepPomodoro = 0
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
