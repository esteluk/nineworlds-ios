//
//  ProgramDetailsCell.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 03/08/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import UIKit

class ProgramDetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    func configure(program: Program) {
        self.titleLabel.text = program.title
        self.dateLabel.text = program.listDetail
        self.tagsLabel.text = program.tagString
        
        self.backgroundColor = UIColor.whiteColor()
        
        // Set some shadows
        self.layer.masksToBounds = false
        self.layer.contentsScale = UIScreen.mainScreen().scale
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSizeMake(0, 2)
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).CGPath
        self.layer.shouldRasterize = true
    }
}
