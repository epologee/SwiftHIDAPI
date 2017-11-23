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
