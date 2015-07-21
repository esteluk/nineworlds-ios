//
//  DetailViewController.swift
//  Nine Worlds
//
//  Created by Nathan Wong on 14/07/2015.
//  Copyright (c) 2015 Nathan Wong. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailTracksLabel: UILabel!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var detailItem: Program? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: Program = self.detailItem {
            if let label = self.detailTitleLabel {
                label.text = detail.title
            }
            if let label = self.detailDescriptionLabel {
                label.text = detail.programDescription
            }
            if let label = self.detailTracksLabel {
                label.text = detail.tagString
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

