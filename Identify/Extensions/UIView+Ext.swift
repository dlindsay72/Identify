//
//  UIView+Ext.swift
//  Identify
//
//  Created by Dan Lindsay on 2017-11-06.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import UIKit

extension UIView {
    func setupViews(cornerRadius: CGFloat) {
        self.layer.shadowColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = cornerRadius
    }
}


