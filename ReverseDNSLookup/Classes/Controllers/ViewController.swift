//
//  ViewController.swift
//  ReverseDNSLookup
//
//  Created by Alexandre Giguere on 2017-08-21.
//  Copyright © 2017 Alexandre Giguere. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var hostNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func resolveButtonTapped(_ sender: UIButton) {
        guard let address = addressTextField.text, !address.isEmpty else { return }
        
        let lookup = ReverseDNSLookup(adress: address)
        
        lookup.resolve { (hostName) in
            self.hostNameLabel.text = hostName ?? "not found"
        }
    }
}

