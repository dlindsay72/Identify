//
//  RoundedShadowButton.swift
//  Identify
//
//  Created by Dan Lindsay on 2017-11-06.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import UIKit

class RoundedShadowButton: UIButton {

    override func awakeFromNib() {
        setupViews(cornerRadius: self.frame.height / 2)
    }

}
