//
//  ABICoder.swift
//  EthiOs
//
//  Created by Isaías Lima on 17/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit

class ABICoder {

    // ATENÇÃO : TODA STRING PROCESSADA POR ESTAS ROTINAS NÃO DEVE PASSAR DE 256 CARACTERES EM UTF8 !!!

    class func encode_uintSingle(param: UInt8) -> String {
        let data = Data(bytes: [param])
        var hex = data.toHexString()
        for _ in 0..<(64 - hex.count) {
            hex = "0" + hex
        }
        return hex
    }

    class func decode_uintSingle(abiHex: String) -> UInt8 {
        return UInt8(abiHex, radix: 16) ?? 0
    }

    class func decode_uintArray(abiHex: String) -> [UInt8] {
        if abiHex.count < 256 {
            return []
        }
        let index = abiHex.index(abiHex.startIndex, offsetBy: 128)
        let head = abiHex[..<index]
        guard let c = UInt8(head.replacingOccurrences(of: "000000000000000000000000000000000000000000000000000000000000002", with: ""), radix: 16) else {
                return []
        }
        let count = Int(c)
        let data = abiHex.replacingOccurrences(of: head, with: "")
        var decoded: [UInt8] = []
        for i in 0..<count {
            let start = String.Index(encodedOffset: i * 64)
            let end = String.Index(encodedOffset: (i * 64) + 64)
            let single = String(data[start..<end])
            decoded.append(decode_uintSingle(abiHex: single))
        }
        return decoded
    }

    class func decode_string(abiHex: String) -> String {
        //        00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000006226a6f7365220000000000000000000000000000000000000000000000000000
        //        00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000007226a6f7365612200000000000000000000000000000000000000000000000000
        //        0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000f224a6fc3a36f20416d6fc3aa646f220000000000000000000000000000000000
        //        0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001c2271776572747975696f706173646667686a6b6c7a786376626e6d2200000000
        //        000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000072230313233342200000000000000000000000000000000000000000000000000
        //        0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002e22323232323232323232323232323232323232323232323232323232323232323232323232323232323232323222000000000000000000000000000000000000
        // 000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c62232323232323232323232323232323232353433353631343331343337323135343332343533373231343332353433353231343533323135373435333237313534333732353134333237353437323534333237313534323237373737373737373737373737373737373737373737373737373737373737373737323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232220000000000000000000000000000000000000000000000000000
        if abiHex.count < 192 {
            return ""
        }
        let index = abiHex.index(abiHex.startIndex, offsetBy: 128)
        let head = abiHex[..<index]
        guard let c = UInt8(head.replacingOccurrences(of: "000000000000000000000000000000000000000000000000000000000000002", with: ""), radix: 16) else {
            return ""
        }
        let count = Int(c)
        let data = abiHex.replacingOccurrences(of: head, with: "")
        let start = String.Index(encodedOffset: 2)
        let end = data.index(start, offsetBy: 2 * (count - 2))
        let sub = data[start..<end]

        var bytes: [UInt8] = []
        for i in 1...(count - 2) {
            let first = String.Index(encodedOffset: 2 * i)
            let nexts = String.Index(encodedOffset: (2 * i) + 1)
            let one = String(sub[first])
            let two = String(sub[nexts])
            let hex = one + two
            bytes.append(UInt8(hex, radix: 16) ?? 0)
        }

        return String(bytes: bytes, encoding: .utf8) ?? ""
    }

    class func encode_string(param: String) -> String {
        let utf8 = [UInt8](param.utf8)
        var hex = ""
        for u in utf8 {
            hex = hex + Data(bytes: [u]).toHexString()
        }
        let sub = "22" + hex + "22"
        let count = utf8.count + 2
        let count8 = UInt8(count)
        let head = "0000000000000000000000000000000000000000000000000000000000000020" + encode_uintSingle(param: count8)
        var body = head + sub

        for _ in 0..<(64 - (body.count % 64)) {
            body = body + "0"
        }

        return body
    }

    class func decode_bool(param: String) -> Bool {
        let response = param.suffix(1)
        return String(response) == "1"
    }
}
