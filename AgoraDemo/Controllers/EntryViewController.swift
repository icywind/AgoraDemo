//
//  ViewController.swift
//  AgoraDemo
//
//  Created by Rickie on 9/11/19.
//  Copyright © 2019 Rickie. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textField.delegate = self
        if let url = URL(string: KeyCenter.ConfigURL) {
            NetworkController.shared.fetch(url) { [unowned self] (config) in
                if let cfg = config {
                    KeyCenter.Token = cfg.token
                    if let expires = NetworkController.shared.makeDate(cfg.expires) {
                        let now = Date()
                        if expires < now {
                            DispatchQueue.main.async {
                                self.markOnline(false)
                            }
                        }
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MultiVideoViewController {
           controller.Channel_ID = textField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        }
    }
}

extension EntryViewController : UITextFieldDelegate
{
    func markOnline(_ online : Bool)
    {
        joinButton.isEnabled = online
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        markOnline(false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text == nil || textField.text!.count == 0 {
            markOnline(false)
        } else {
            markOnline(true)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        markOnline(false)
        return true
    }
}
