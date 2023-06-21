//
//  OverlayView.swift
//  BarcodeTextScanner
//
//  Created by Zoljargal Jargalsaikhan on 2023/06/21.
//

import Foundation
import SwiftUI

class HighlightView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 1, alpha: 0.5)
   }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
