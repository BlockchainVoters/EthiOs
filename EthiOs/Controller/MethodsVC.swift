//
//  MethodsVC.swift
//  EthiOs
//
//  Created by Isaías Lima on 18/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import EthereumKit
import CryptoEthereumSwift

class MethodsVC: UIViewController {

    @IBOutlet weak var tabelView: UITableView!

    fileprivate var methods: List<ChainContractMethod>?
    fileprivate var spinner: UIActivityIndicatorView!

    fileprivate var config: Configuration!
    fileprivate var geth: Geth!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabelView.delegate = self
        self.tabelView.dataSource = self

        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.spinner.hidesWhenStopped = true
        let item = UIBarButtonItem(customView: self.spinner)
        self.navigationItem.rightBarButtonItems = [item]

        self.config = Configuration(network: ChainService.network, nodeEndpoint: ChainService.node, etherscanAPIKey: ChainService.etherscanKey, debugPrints: false)
        self.geth = Geth(configuration: self.config)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.spinner.startAnimating()
        ChainService.download_contract { (status) in
            self.spinner.stopAnimating()
            switch status {
            case .success(let abi):
                self.methods = abi.methods.filter({ (method) -> Bool in
                    let candidate = method.name != "insert_candidate"
                    let shut = method.name != "shut_down"
                    let delete = method.name != "delete_candidate"
                    let votes = method.name != "get_votes"
                    return candidate && shut && delete && votes
                })
                self.tabelView.reloadData()
            case .failure(let error):
                print(#function, error.localizedDescription)
            }
        }
    }
}

extension MethodsVC: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.methods?.count ?? 0
    }
}

extension MethodsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "method", for: indexPath)

        let method = self.methods![indexPath.row]
        cell.textLabel?.text = method.name
        cell.detailTextLabel?.text = method.mutability

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let method = self.methods![indexPath.row]

        switch method.name {
        case "get_candidates":

            self.spinner.startAnimating()
            ChainService.contract_viewcall(account_address: ChainAccount.address, method: method, abiEncodedParams: "0000000000000000000000000000000000000000000000000000000000000000") { (status) in
                self.spinner.stopAnimating()
                switch status {
                case .success(let msg):
                    let decoded = ABICoder.decode_uintArray(abiHex: msg)
                    var response = ""
                    for integer in decoded {
                        response = response + " \(integer)"
                    }
                    self.showAlertController(withTitle: "Resposta:", andMessage: response)
                case .failure(let error):
                    self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
                }
            }

        case "has_voted":

            self.spinner.startAnimating()
            ChainService.contract_viewcall(account_address: ChainAccount.address, method: method, abiEncodedParams: "0000000000000000000000000000000000000000000000000000000000000000") { (status) in
                self.spinner.stopAnimating()
                switch status {
                case .success(let msg):
                    let decoded = ABICoder.decode_bool(param: msg)
                    self.showAlertController(withTitle: "Resposta:", andMessage: "\(decoded)")
                case .failure(let error):
                    self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
                }
            }

        case "has_joined":

            self.spinner.startAnimating()
            ChainService.contract_viewcall(account_address: ChainAccount.address, method: method, abiEncodedParams: "0000000000000000000000000000000000000000000000000000000000000000") { (status) in
                self.spinner.stopAnimating()
                switch status {
                case .success(let msg):
                    let decoded = ABICoder.decode_bool(param: msg)
                    self.showAlertController(withTitle: "Resposta:", andMessage: "\(decoded)")
                case .failure(let error):
                    self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
                }
            }

        case "get_candidate":

            var field: UITextField = UITextField()

            let controller = UIAlertController(title: method.name, message: "Insira os dados abaixo", preferredStyle: .alert)
            controller.addTextField { (tf) in
                if let input = method.inputs.first {
                    tf.placeholder = input
                    field = tf
                }
            }
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            let call = UIAlertAction(title: "Executar", style: .default) { (action) in
                if let text = field.text {
                    if text == "" { return }
                    guard let value = UInt8(text) else { return }
                    let encoded = ABICoder.encode_uintSingle(param: value)
                    self.spinner.startAnimating()
                    ChainService.contract_viewcall(account_address: ChainAccount.address, method: method, abiEncodedParams: encoded) { (status) in
                        self.spinner.stopAnimating()
                        switch status {
                        case .success(let msg):
                            let decoded = ABICoder.decode_candidate(param: msg)
                            self.showAlertController(withTitle: "Resposta:", andMessage: "\(decoded)")
                        case .failure(let error):
                            self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
                        }
                    }
                }
            }
            controller.addAction(cancel)
            controller.addAction(call)
            self.present(controller, animated: true, completion: nil)

        case "check_vote":

            var field: UITextField = UITextField()

            let controller = UIAlertController(title: method.name, message: "Insira os dados abaixo", preferredStyle: .alert)
            controller.addTextField { (tf) in
                if let input = method.inputs.first {
                    tf.isSecureTextEntry = true
                    tf.placeholder = input
                    field = tf
                }
            }
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            let call = UIAlertAction(title: "Executar", style: .default) { (action) in
                if let text = field.text {
                    if text == "" { return }
                    guard let encoded = ABICoder.encode_hash(param: text) else {
                        return
                    }
                    self.spinner.startAnimating()
                    ChainService.contract_viewcall(account_address: ChainAccount.address, method: method, abiEncodedParams: encoded) { (status) in
                        self.spinner.stopAnimating()
                        switch status {
                        case .success(let msg):
                            let decoded = ABICoder.decode_uintSingle(abiHex: msg)
                            self.showAlertController(withTitle: "Resposta:", andMessage: "\(decoded)")
                        case .failure(let error):
                            self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
                        }
                    }
                }
            }
            controller.addAction(cancel)
            controller.addAction(call)
            self.present(controller, animated: true, completion: nil)

        case "get_appuration":

            var field: UITextField = UITextField()

            let controller = UIAlertController(title: method.name, message: "Insira os dados abaixo", preferredStyle: .alert)
            controller.addTextField { (tf) in
                if let input = method.inputs.first {
                    tf.placeholder = input
                    field = tf
                }
            }
            let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            let call = UIAlertAction(title: "Executar", style: .default) { (action) in
                if let text = field.text {
                    if text == "" { return }
                    guard let value = UInt8(text) else { return }
                    let encoded = ABICoder.encode_uintSingle(param: value)
                    self.spinner.startAnimating()
                    ChainService.contract_viewcall(account_address: ChainAccount.address, method: method, abiEncodedParams: encoded) { (status) in
                        self.spinner.stopAnimating()
                        switch status {
                        case .success(let msg):
                            let decoded = ABICoder.decode_uintHuge(abiHex: msg)
                            self.showAlertController(withTitle: "Resposta:", andMessage: "\(decoded)")
                        case .failure(let error):
                            self.showAlertController(withTitle: "Erro :(", andMessage: error.localizedDescription)
                        }
                    }
                }
            }
            controller.addAction(cancel)
            controller.addAction(call)
            self.present(controller, animated: true, completion: nil)

        default:
            print(#function, "função não implementada")
            self.showAlertController(withTitle: "Erro :(", andMessage: "Este método de contrato não foi implementado ainda pela plataforma.")
        }
    }
}
