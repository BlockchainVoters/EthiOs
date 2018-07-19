//
//  UIViewControllerExtension.swift
//  EthiOs
//
//  Created by Isaías Lima on 18/07/2018.
//  Copyright © 2018 Isaías. All rights reserved.
//

import UIKit

extension UIViewController {

    func showAlertController(withTitle title: String, andMessage message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Entendido", style: .cancel, handler: nil)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
}
