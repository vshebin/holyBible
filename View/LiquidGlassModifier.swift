//
//  LiquidGlassModifier.swift
//  HolyBible
//
//  Created by Shebin Vins on 11/21/26.
//

import SwiftUI

struct AdaptiveGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var tintColor: Color? = nil
    var isProminent: Bool = false

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // Applies to iOS 26, iOS 27, and all future iOS versions
            if let tint = tintColor {
                content
                    .glassEffect(
                        .regular.tint(tint).interactive(),
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
            } else {
                content
                    .glassEffect(
                        .regular.interactive(),
                        in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    )
            }
        } else {
            // Clean, high-contrast style for iOS 15 – 25
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isProminent ? Color(red: 0.55, green: 0.38, blue: 0.12).opacity(0.88) : Color.black.opacity(0.6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        }
    }
}

extension View {
    /// Applies native Liquid Glass on iOS 26/27+, and clean lightweight surfaces on iOS 15+
    func adaptiveLiquidGlass(
        cornerRadius: CGFloat = 16,
        tint: Color? = nil,
        isProminent: Bool = false
    ) -> some View {
        modifier(AdaptiveGlassModifier(cornerRadius: cornerRadius, tintColor: tint, isProminent: isProminent))
    }
}
