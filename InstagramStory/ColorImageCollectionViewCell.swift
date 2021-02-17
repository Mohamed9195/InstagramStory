//
//  ColorImageCollectionViewCell.swift
//  Hebat
//
//  Created by mohamed hashem on 10/02/2021.
//  Copyright © 2021 mohamed hashem. All rights reserved.
//

import UIKit

class ColorImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var colorButton: UIButton!

    var selectColorClosure: (() -> ())?

    @IBAction func selectColor(_ sender: UIButton) {
        selectColorClosure?()
    }
}
