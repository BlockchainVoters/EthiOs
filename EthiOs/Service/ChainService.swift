//
//  ChainService.swift
//  EthiOs
//
//  Created by Isaías Lima on 04/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import EthereumKit
import CryptoSwift
import CryptoEthereumSwift
import JASON
import Alamofire
import AlamofireImage

class ChainService {

    static public let network: Network = .ropsten
    static private let infuraKey = "3NvOsJAFQ0UFPFcBafxe"
    static public var node: String {
        switch network {
        case .main:
            return "https://mainnet.infura.io/" + infuraKey
        case .kovan:
            return "https://kovan.infura.io/" + infuraKey
        case .ropsten:
            return "https://ropsten.infura.io/" + infuraKey
        default:
            return "https://ropsten.infura.io/" + infuraKey
        }
    }
    static public let etherscanKey = "VCY6JC3G77VCFWYD7TMJW293W4KK9TT54R"

}
