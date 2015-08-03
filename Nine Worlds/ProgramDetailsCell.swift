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
    }
}
