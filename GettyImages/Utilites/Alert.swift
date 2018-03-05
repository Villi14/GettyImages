//
//  Alert.swift
//  GettyImages
//
//  Created by Alexandr Velikotskiy on 3/4/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class Alert {
    class func displayIn(_ controller: UIViewController?, title: String, message: String) {
        if let vc = controller {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            vc.present(alert, animated: true, completion: nil)
        }
    }
}

