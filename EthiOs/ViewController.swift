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

    var address: String!
    var privKey: String!
    var publKey: String!

    var config: Configuration!
    var geth: Geth!

    override func viewDidLoad() {
        super.viewDidLoad()

        let acc = ChainAccount()
        let mnemonic = acc.createAccount(identifier: "isaiahlima18", password: "1234")

        print(#function, mnemonic)

//        self.config = Configuration(network: .ropsten, nodeEndpoint: node, etherscanAPIKey: etherscan, debugPrints: true)
//        self.geth = Geth(configuration: self.config)
//
//        self.createWallet()
//
//        self.getBalance()
    }

    func createWallet() {
        do {
            let defaults = UserDefaults.standard
            if let account = defaults.object(forKey: "account") as? [String : String] {

                self.address = account["addrss"]
                self.privKey = account["privat"]

            } else {

                let mnemonic = Mnemonic.create(strength: .hight, language: .english)
                let seed = try Mnemonic.createSeed(mnemonic: mnemonic, withPassphrase: pass)
                let wallet = try Wallet(seed: seed, network: .ropsten, debugPrints: true)
                let address = wallet.generateAddress()
                let privkey = wallet.dumpPrivateKey()

                let acc = ["addrss" : address,
                           "privat" : privkey]

                defaults.set(acc, forKey: "account")
                defaults.synchronize()

                self.address = address
                self.privKey = privkey
            }
        } catch {

        }
    }

    func getBalance() {
        self.geth.getBalance(of: self.address, blockParameter: .latest) { (result) in
            switch result {
            case .success(let balance):
                print(#function, balance.wei)
            case .failure(let error):
                print(#function, error.localizedDescription)
            }
        }
    }

}

