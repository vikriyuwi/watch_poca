//
//  PickerStyle.swift
//  poca Watch App
//
//  Created by win win on 26/05/24.
//
import SwiftUI

extension Picker {
func focusBorderColor(color: Color) -> some View {
    let isWatchOS7: Bool = {
        if #available(watchOS 7, *) {
            return true
        }
        return false
    }()

    let padding: EdgeInsets = {
        if isWatchOS7 {
            return .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        }
        return .init(top: 8.5, leading: 0.5, bottom: 8.5, trailing: 0.5)
    }()

    return self
        .overlay(
            RoundedRectangle(cornerRadius: isWatchOS7 ? 12 : 12)
                .stroke(color, lineWidth: isWatchOS7 ? 4 : 3.5)
                .offset(y: isWatchOS7 ? 0 : 0)
                .padding(padding)
        )
  }
}
