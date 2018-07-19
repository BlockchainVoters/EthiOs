//
//  AccountVC.swift
//  EthiOs
//
//  Created by Isaías Lima on 18/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit

class AccountVC: UIViewController {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.usernameTF.delegate = self
        self.passwordTF.delegate = self

        self.navigationItem.title = ChainAccount.address
        self.navigationItem.prompt = ChainAccount.privKey
    }

    @IBAction func access(_ sender: Any) {
        let identifier = self.usernameTF.text!
        let password = self.passwordTF.text!

        if identifier == "" || password == "" {
            return
        }

        let status = ChainAccount.getAccount(identifier: identifier, password: password)
        switch status {
        case .failure(let error):
            print(#function, error)
            let sts = ChainAccount.createAccount(identifier: identifier, password: password)
            switch sts {
            case .failure(let e):
                print(#function, e)
                self.showAlertController(withTitle: "Erro :(", andMessage: "Esta conta não existe e tampouco pôde ser criada. " + e.localizedDescription)
            case .success(let data):
                print(#function, data)
                self.showAlertController(withTitle: "Eba :)", andMessage: "Conta criada com sucesso. Não perca esta senha nem o nome de usuário, caso contrário você perderá sua conta, para sempre (é sério).")
                self.navigationItem.title = ChainAccount.address
                self.navigationItem.prompt = ChainAccount.privKey
            }
        case .success(let data):
            print(#function, data)
            self.showAlertController(withTitle: "Eba :)", andMessage: "Conta recuperada com sucesso.")
            self.navigationItem.title = ChainAccount.address
            self.navigationItem.prompt = ChainAccount.privKey
        }
    }
}

extension AccountVC: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
