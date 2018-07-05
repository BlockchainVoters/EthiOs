//
//  ViewController.swift
//  EthiOs
//
//  Created by Isaías Lima on 03/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import EthereumKit
import CryptoSwift
import CryptoEthereumSwift

let pass = "qwerty1234567890"
let key = "3NvOsJAFQ0UFPFcBafxe"
let node = "https://ropsten.infura.io/" + key
let etherscan = "VCY6JC3G77VCFWYD7TMJW293W4KK9TT54R"

class ViewController: UIViewController {

    var geth: Geth!

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = Configuration(network: ChainService.network, nodeEndpoint: ChainService.node, etherscanAPIKey: ChainService.etherscanKey, debugPrints: false)
        self.geth = Geth(configuration: configuration)

        let encoded = "get_candidate(uint8)".sha3(.keccak256)
        let bytes = "0x" + String(encoded.prefix(8)) + "000000000000000000000000000000000000000000000000000000000000001e"

        self.geth.call(from: nil, to: ChainService.contractAddress, gasLimit: nil, gasPrice: nil, value: nil, data: bytes, blockParameter: .latest) { (result) in
            switch result {
            case .success(let obj):
                print(#function, obj)
            case .failure(let error):
                print(#function, error.localizedDescription)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        ChainService.download_contract { (status) in
//
//        }
    }
}

