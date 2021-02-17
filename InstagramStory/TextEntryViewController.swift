//
//  StoryPopViewController.swift
//  Hebat
//
//  Created by mohamed hashem on 23/11/2020.
//  Copyright © 2020 mohamed hashem. All rights reserved.
//

import UIKit

protocol TextEntryDelegate {
    func didAdd(text: String)
}

class TextEntryViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    var delegate: TextEntryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }

    @IBAction func didSelectDone(_ sender: Any) {
        self.delegate?.didAdd(text: textField.text!)
    }
}
