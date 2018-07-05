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

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ChainService.download_contract { (status) in

        }
    }
}

