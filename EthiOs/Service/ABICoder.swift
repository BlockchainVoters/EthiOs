//
//  ABICoder.swift
//  EthiOs
//
//  Created by Isaías Lima on 17/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import CryptoSwift

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

    class func decode_uintHuge(abiHex: String) -> UInt32 {
        return UInt32(abiHex, radix: 16) ?? 0
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

    class func decode_candidate(param: String) -> (String, UInt8, String, String) {
        // só funciona com este tipo de contrato

        if param == "" {
            return ("",0,"","")
        }

        var matrix: [String] = []
        for _ in 0..<10 {
            matrix.append("")
        }
        for i in 0..<640 {
            let index = String.Index(encodedOffset: i)
            if (i < 64) {
                matrix[0] = matrix[0] + String(param[index])
            } else if (i >= 64 && i < 128) {
                matrix[1] = matrix[1] + String(param[index])
            } else if (i >= 128 && i < 192) {
                matrix[2] = matrix[2] + String(param[index])
            } else if (i >= 192 && i < 256) {
                matrix[3] = matrix[3] + String(param[index])
            } else if (i >= 256 && i < 320) {
                matrix[4] = matrix[4] + String(param[index])
            } else if (i >= 320 && i < 384) {
                matrix[5] = matrix[5] + String(param[index])
            } else if (i >= 384 && i < 448) {
                matrix[6] = matrix[6] + String(param[index])
            } else if (i >= 448 && i < 512) {
                matrix[7] = matrix[7] + String(param[index])
            } else if (i >= 512 && i < 576) {
                matrix[8] = matrix[8] + String(param[index])
            } else {
                matrix[9] = matrix[9] + String(param[index])
            }
        }
        print(#function, matrix)

        let name = (String(data: Data(hex: matrix[5]), encoding: .utf8) ?? "").replacingOccurrences(of: "\0", with: "")
        let party = (String(data: Data(hex: matrix[7]), encoding: .utf8) ?? "").replacingOccurrences(of: "\0", with: "")
        let vice = (String(data: Data(hex: matrix[9]), encoding: .utf8) ?? "").replacingOccurrences(of: "\0", with: "")

        let number = decode_uintSingle(abiHex: matrix[1])
        
        return (name,number,party,vice)
    }

    class func encode_vote(vote: UInt8, _hash: String) -> String {

        guard let passdata = _hash.data(using: .utf8) else {
            return ""
        }

        let hash = passdata.sha256().toHexString()

        let utf8 = [UInt8](hash.utf8)
        var hex = ""
        for u in utf8 {
            hex = hex + Data(bytes: [u]).toHexString()
        }
        let sub = "22" + hex + "22"
        let count = utf8.count + 2
        let count8 = UInt8(count)
        let vote = encode_uintSingle(param: vote)
        let head = vote + "0000000000000000000000000000000000000000000000000000000000000040" + encode_uintSingle(param: count8)
        var body = head + sub

        for _ in 0..<(64 - (body.count % 64)) {
            body = body + "0"
        }

        return body
    }

    class func encode_hash(param: String) -> String? {

        guard let passdata = param.data(using: .utf8) else {
            return nil
        }

        let hash = passdata.sha256().toHexString()

        let utf8 = [UInt8](hash.utf8)
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
}
