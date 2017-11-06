//
//  CameraVC.swift
//  Identify
//
//  Created by Dan Lindsay on 2017-11-06.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
    
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var itemImageView: RoundedShadowImageView!
    @IBOutlet weak var flashOffBtn: RoundedShadowButton!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var roundedShadowView: RoundedShadowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func flashOffBtnWasPressed(_ sender: Any) {
        
    }
}

