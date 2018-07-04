//
//  ChainAccount.swift
//  EthiOs
//
//  Created by Isaías Lima on 04/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import JASON
import EthereumKit
import CryptoSwift
import CryptoEthereumSwift
import KeychainSwift

enum ChainAccountStatus<T> {
    case success(T)
    case failure(Error)
}

class ChainAccount: NSObject {

    var address: String // the account's public address

    override init() {
        self.address = "0x0"
        super.init()
    }

    func createAccount(identifier: String, password: String) -> ChainAccountStatus<[String]> {

        guard let passdata = password.data(using: .utf8) else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "A senha fornecida não pôde ser codificada, tente novamente."])
            return .failure(error)
        }

        let hash = passdata.sha256().toHexString()

        do {
            let mnemonic = Mnemonic.create(strength: .hight, language: .english)
            let seed = try Mnemonic.createSeed(mnemonic: mnemonic, withPassphrase: hash)
            let wallet = try Wallet(seed: seed, network: ChainService.network, debugPrints: false)

            let addr = wallet.generateAddress()
            let priv = wallet.dumpPrivateKey()

            let keychain = KeychainSwift()
            keychain.set(priv, forKey: hash)
            keychain.set(addr, forKey: identifier)

            return .success(mnemonic)

        } catch {
            return .failure(error)
        }
    }

}
