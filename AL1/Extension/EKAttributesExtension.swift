//
//  EKAttributesExtension.swift
//  AL1
//
//  Created by cashlee on 2025/12/20.
//

import UIKit
import SwiftEntryKit

extension EKAttributes {
    static func bottomSheet(_ height: CGFloat? = nil,
                            radius: CGFloat = 25,
                            backgroundColor: UIColor = AppColorStyle.shared.backgroundWhite) -> EKAttributes {
        var attributes: EKAttributes = .bottomFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(hex: "0x485563").withAlphaComponent(0.3),
                                                          dark: UIColor(hex: "0x29323c").withAlphaComponent(0.2)))
        attributes.entryBackground = .color(color: EKColor(backgroundColor))
        attributes.roundCorners = .top(radius: radius)
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.5,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.35)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.35)
            )
        )
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 6
            )
        )
        if let height {
            attributes.positionConstraints.size = .init(
                width: .fill,
                height: .constant(value: height)
            )
        } else {
            attributes.positionConstraints.size = .init(
                width: .fill,
                height: .fill
            )
        }
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
        attributes.statusBar = .dark
        return attributes
    }
}


extension EKAttributes
{
    static func centerDialog() -> EKAttributes
    {
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(hex: "0x485563").withAlphaComponent(0.3),
                                                          dark: UIColor(hex: "0x29323c").withAlphaComponent(0.2)))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.entranceAnimation = .init(
            scale: .init(
                from: 0.9,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        
        attributes.exitAnimation = .init(
            fade: .init(
                from: 1,
                to: 0,
                duration: 0.2
            )
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.35)
            )
        )
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 6
            )
        )
        attributes.positionConstraints.size = .init(width: .fill, height: .fill)
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
        attributes.statusBar = .dark
        return attributes
    }
    /*
     static func centerDialog() -> EKAttributes {
         
         // 4. 配置 SwiftEntryKit 属性
         var attributes = EKAttributes.centerFloat
         attributes.displayDuration = .infinity
         attributes.positionConstraints.size = .init(width: .constant(value: UIScreen.main.bounds.width),
                                                     height: .constant(value: UIScreen.main.bounds.height))
         
         attributes.displayMode = EKAttributes.DisplayMode.inferred
         attributes.windowLevel = .alerts
         attributes.displayDuration = .infinity
         attributes.hapticFeedbackType = .success
         attributes.screenInteraction = .absorbTouches
         attributes.entryInteraction = .absorbTouches
         attributes.scroll = .disabled
         attributes.entryBackground = .color(
             color: EKColor.init(light: UIColor(hex: "0x485563").withAlphaComponent(0.3),
                                 dark: UIColor(hex: "0x29323c").withAlphaComponent(0.2))
         )
         attributes.entranceAnimation = .init(
             scale: .init(
                 from: 0.9,
                 to: 1,
                 duration: 0.4,
                 spring: .init(damping: 1, initialVelocity: 0)
             ),
             fade: .init(
                 from: 0,
                 to: 1,
                 duration: 0.3
             )
         )
         attributes.exitAnimation = .init(
             fade: .init(
                 from: 1,
                 to: 0,
                 duration: 0.2
             )
         )
         attributes.shadow = .active(
             with: .init(
                 color: .black,
                 opacity: 0.3,
                 radius: 5
             )
         )
         attributes.positionConstraints.maxSize = .init(
             width: .constant(value: UIScreen.main.bounds.width),
             height: .intrinsic
         )
         return attributes
     }
     */
}
