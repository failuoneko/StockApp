//
//  ErrorAlert.swift
//  StockApp
//
//  Created by L on 2021/11/5.
//

import UIKit

extension UIViewController {
    
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
