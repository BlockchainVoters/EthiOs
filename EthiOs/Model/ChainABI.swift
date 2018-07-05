//
//  ChainABI.swift
//  EthiOs
//
//  Created by Isaías Lima on 04/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import JASON
import Realm
import RealmSwift

class ChainContractMethod: Object {
    @objc dynamic var constant: Bool = false
    var inputs: List<String> = List<String>()
    @objc dynamic var name: String = ""
    var outputs: List<String> = List<String>()
    @objc dynamic var payable: Bool = false
    @objc dynamic var mutability: String = ""
    @objc dynamic var type: String = ""
}

class ChainABI: Object {
    var methods: List<ChainContractMethod> = List<ChainContractMethod>()
}

//class ChainABI: NSObject {
//
//    var methods: [ChainContractMethod] = []
//
//    convenience init(jsArray: JSON?) {
//        if let arr = jsArray {
//            let meths = arr.compactMap { (json) -> ChainContractMethod? in
//                guard let constant = json["constant"].bool
//                    , let inputs = json["inputs"].jsonArray
//                    , let name = json["name"].string
//                    , let outputs = json["outputs"].jsonArray
//                    , let payable = json["payable"].bool
//                    , let mutability = json["stateMutability"].string
//                    , let type = json["type"].string else {
//                        return nil
//                }
//                let inps = inputs.compactMap({ (jsn) -> ChainContractInput? in
//                    guard let n = jsn["name"].string
//                        , let t = jsn["type"].string else {
//                            return nil
//                    }
//                    return ChainContractInput(name: n,
//                                              type: t)
//                })
//                let outs = outputs.compactMap({ (jsn) -> ChainContractOutput? in
//                    guard let n = jsn["name"].string
//                        , let t = jsn["type"].string else {
//                            return nil
//                    }
//                    return ChainContractOutput(name: n,
//                                              type: t)
//                })
//                return ChainContractMethod(constant: constant,
//                                           inputs: inps,
//                                           name: name,
//                                           outputs: outs,
//                                           payable: payable,
//                                           mutability: mutability,
//                                           type: type)
//            }
//        }
//    }
//}
