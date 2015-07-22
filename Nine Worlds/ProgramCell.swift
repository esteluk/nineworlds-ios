//
//  ProgramCell.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 17/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import UIKit

class ProgramCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tracksLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    func configure(programItem: Program) {
        self.titleLabel.text = programItem.title
        self.tracksLabel.text = programItem.tagString
        self.timeLabel.text = programItem.listDetail
        self.tagLabel.text = programItem.warningTag
    }

}
