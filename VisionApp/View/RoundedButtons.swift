//
//  RoundedButtons.swift
//  VisionApp
//
//  Created by Ramit sharma on 08/08/18.
//  Copyright © 2018 Ramit sharma. All rights reserved.
//

import UIKit

class RoundedButtons: UIButton {
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
