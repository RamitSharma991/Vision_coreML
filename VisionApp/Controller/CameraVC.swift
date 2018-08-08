//
//  CameraVC.swift
//  VisionApp
//
//  Created by Ramit sharma on 06/08/18.
//  Copyright © 2018 Ramit sharma. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {

//Outlets
    
    
    
    @IBOutlet weak var captureImgview: RoundedImageView!
    @IBOutlet weak var flashOutlet: RoundedButtons!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var identificationLbl: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedLblView: RoundedShadowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
