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
import KeychainSwift

enum ChainServiceStatus<T> {
    case success(T)
    case failure(Error)
}

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
    static public let contractAddress = "0x57ac3ab7355a9279e95f525e55fe5a73e58f9acc"
    static private var etherscan: String {
        switch network {
        case .main:
            return "http://api.etherscan.io/api"
        case .kovan:
            return "http://api-kovan.etherscan.io/api"
        case .ropsten:
            return "http://api-ropsten.etherscan.io/api"
        default:
            return "http://api-ropsten.etherscan.io/api"
        }
    }

    static public var cache: [String : Any] = [:]

    class public func download_contract(callback: @escaping (ChainServiceStatus<ChainABI>) -> Void) {

        if let abi = cache["abi"] as? ChainABI {
            callback(.success(abi))
            return
        }

        guard let url = URL(string: etherscan + "?module=contract&action=getabi&address=" + contractAddress) else {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "Endereço para download do contrato não encontrado."])
            callback(.failure(error))
            return
        }

        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default).responseJSON { (response) in
            guard let value = response.result.value else {
                let error = response.result.error!
                callback(.failure(error))
                return
            }
            let json = JSON(value)
            guard let result = json["result"].string else {
                let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O contrato da eleição é inexistente."])
                callback(.failure(error))
                return
            }
            let abi = JSON(result)

            let meths = abi.compactMap { (json) -> ChainContractMethod? in
                guard let constant = json["constant"].bool
                    , let inputs = json["inputs"].jsonArray
                    , let name = json["name"].string
                    , let outputs = json["outputs"].jsonArray
                    , let payable = json["payable"].bool
                    , let mutability = json["stateMutability"].string
                    , let type = json["type"].string else {
                        return nil
                }
                let inps = inputs.compactMap({ (jsn) -> String? in
                    guard let n = jsn["name"].string
                        , let t = jsn["type"].string else {
                            return nil
                    }
                    return n + " : " + t
                })
                let outs = outputs.compactMap({ (jsn) -> String? in
                    guard let n = jsn["name"].string
                        , let t = jsn["type"].string else {
                            return nil
                    }
                    return n + " : " + t
                })
                let method = ChainContractMethod()
                method.constant = constant
                method.inputs.append(contentsOf: inps)
                method.outputs.append(contentsOf: outs)
                method.name = name
                method.payable = payable
                method.mutability = mutability
                method.type = type
                return method
            }

            let chainAbi = ChainABI()
            chainAbi.methods.append(contentsOf: meths)

            cache["abi"] = chainAbi

            callback(.success(chainAbi))
        }
    }

    class public func contract_viewcall(account_address: String, method: ChainContractMethod, abiEncodedParams: String, callback: @escaping (ChainServiceStatus<String>) -> Void) {

        if method.mutability != "view" {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O método chamado não é de leitura. Realize uma transação ou recorra a um método de leitura."])
            callback(.failure(error))
            return
        }

        let configuration = Configuration(network: network, nodeEndpoint: node, etherscanAPIKey: etherscanKey, debugPrints: false)
        let geth = Geth(configuration: configuration)

        var inputs = ""
        for input in method.inputs {
            let split = input.split(separator: ":")
            inputs = inputs + split[1].replacingOccurrences(of: " ", with: "")
        }

        let function = method.name + "(" + inputs + ")"
        let encoded = function.sha3(.keccak256)
        let call = "0x" + String(encoded.prefix(8))

        let bytes = call + abiEncodedParams

        geth.call(from: account_address, to: contractAddress, gasLimit: nil, gasPrice: nil, value: nil, data: bytes, blockParameter: .latest) { (result) in
            switch result {
            case .success(let obj):
                print(#function, obj)
                callback(.success(obj.replacingOccurrences(of: "0x", with: "")))
            case .failure(let error):
                callback(.failure(error))
            }
        }

    }

    class public func contract_transaction(account_address: String, method: ChainContractMethod, abiEncodedParams: String, callback: @escaping (ChainServiceStatus<Bool>) -> Void) {

        if method.mutability != "nonpayable" {
            let error = NSError(domain: NSCocoaErrorDomain, code: 404, userInfo: [NSLocalizedDescriptionKey : "O método chamado não é uma transação."])
            callback(.failure(error))
            return
        }

        let configuration = Configuration(network: network, nodeEndpoint: node, etherscanAPIKey: etherscanKey, debugPrints: false)
        let geth = Geth(configuration: configuration)

        var inputs = ""
        for input in method.inputs {
            let split = input.split(separator: ":")
            inputs = inputs + split[1].replacingOccurrences(of: " ", with: "")
        }

        if method.name == "vote" {
            inputs = "uint8,string"
        }

        let function = method.name + "(" + inputs + ")"
        let encoded = function.sha3(.keccak256)
        let call = /* "0x" + */ String(encoded.prefix(8))

        let bytes = call + abiEncodedParams
        let data = Data(hex: bytes)

        geth.getTransactionCount(of: ChainAccount.address) { (result) in
            switch result {
            case .failure(let error):
                callback(.failure(error))
            case .success(let count):
                geth.getGasPrice(completionHandler: { (res) in
                    switch res {
                    case .failure(let err):
                        callback(.failure(err))
                    case .success(let wei):
                        let raw = RawTransaction(wei: "0", to: contractAddress, gasPrice: Int(wei), gasLimit: 3000000, nonce: count, data: data)
                        let wallet = Wallet(network: network, privateKey: ChainAccount.privKey, debugPrints: false)
                        do {
                            let tx = try wallet.sign(rawTransaction: raw)
                            geth.sendRawTransaction(rawTransaction: tx, completionHandler: { (r) in
                                switch r {
                                case .failure(let e):
                                    callback(.failure(e))
                                case .success(let txHash):
                                    print(#function, txHash.id)
                                    callback(.success(true))
                                }
                            })
                        } catch {
                            callback(.failure(error))
                        }
                    }
                })
            }
        }
    }
}
