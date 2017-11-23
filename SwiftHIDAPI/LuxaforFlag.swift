//
//  LuxoforFlag.swift
//  SwiftHIDAPI
//
//  Created by Eric-Paul Lecluse on 23-11-17.
//

import Foundation
import hidapi

public enum LuxaforFlag {
    private static let vendorId: CUnsignedShort = 0x04d8
    private static let productId: CUnsignedShort = 0xf372

    public static var isConnected: Bool {
        guard let handle = hid_open(vendorId, productId, nil) else {
            return false
        }

        defer {
            hid_close(handle)
        }

        let MAX_STR = 255
        var wstr = [wchar_t](repeating: 0, count: MAX_STR)

        print("Device Info:")
        if hid_get_manufacturer_string(handle, &wstr, MAX_STR) == -1 {
            print("Could not get manufacturer string!")
            return false
        }
        print("  Manufacturer String: \(String(wString: &wstr))")

        if hid_get_product_string(handle, &wstr, MAX_STR) == -1 {
            print("Could not get product string!")
            return false
        }
        print("  Product String: \(String(wString: &wstr))")

        return true
    }
}

public struct LuxaforOperation {
    public var leds: LED
    public var color: LEDColor
    public var transition: Transition

    public init(leds: LED, color: LEDColor, transition: Transition) {
        self.leds = leds
        self.color = color
        self.transition = transition
    }

    fileprivate var operation: [CUnsignedChar] {
        var luxaforOperation = [CUnsignedChar](repeating: 0, count: 9)

        luxaforOperation[0] = 0x0   //report id
        luxaforOperation[1] = transition.type
        luxaforOperation[2] = leds.rawValue
        let rgb = color.rgb
        luxaforOperation[3] = rgb.0 //red color component
        luxaforOperation[4] = rgb.1 //green color component
        luxaforOperation[5] = rgb.2 //blue color component
        luxaforOperation[6] = transition.speed

        return luxaforOperation
    }

    public enum LED: CUnsignedChar {
        case all = 0xFF
        case front1 = 0x1
        case front2 = 0x2
        case front3 = 0x3
        case back1 = 0x4
        case back2 = 0x5
        case back3 = 0x6
    }

    public enum LEDColor {
        case off
        case on(CUnsignedChar, CUnsignedChar, CUnsignedChar)

        fileprivate var rgb: (CUnsignedChar, CUnsignedChar, CUnsignedChar) {
            switch self {
            case .off:
                return (0, 0, 0)
            case let .on(r, g, b):
                return (r, g, b)
            }
        }
    }

    public enum Transition {
        case instant
        case fadeDefault
        case fade(speed: CUnsignedChar)
        case pulse(speed: CUnsignedChar)
        case disco
        case demo

        fileprivate var type: CUnsignedChar {
            switch self {
            case .instant: return 0x1
            case .fadeDefault: fallthrough
            case .fade: return 0x2
            case .pulse: return 0x3
            case .disco: return 0x4
            case .demo: return 0x6
            }
        }

        fileprivate var speed: CUnsignedChar {
            switch self {
            case .instant: return 0
            case .fadeDefault: return 20
            case .fade(let speed): return speed
            case .pulse(let speed): return speed
            case .disco: return 0
            case .demo: return 0
            }
        }
    }
}
