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
    @IBOutlet weak var detailRoomLabel: UILabel!

    @IBOutlet weak var emptyContentLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    
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
                label.attributedText = detail.attributedTitle
            }
            if let label = self.detailDescriptionLabel {
                label.attributedText = detail.attributedDescription
            }
            if let label = self.detailTracksLabel {
                label.text = detail.tagString
            }
            if let label = self.detailRoomLabel {
                label.text = detail.roomString
            }
            
            // Set Favourite button text
            if let button = self.favouriteButton {
                self.updateFavouriteButton(button, programItem: detail)
            }
            
            if let scrollview = self.scrollView {
                scrollView.hidden = false
            }
            
            if let empty = self.emptyContentLabel {
                empty.hidden = true
            }
            
        } else {
            self.scrollView.hidden = true
            self.emptyContentLabel.hidden = false
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

    @IBAction func favouriteButtonPressed(sender: UIBarButtonItem) {
        self.detailItem?.attending = !self.detailItem!.attending
        self.updateFavouriteButton(sender, programItem: self.detailItem!)
    }
    
    func updateFavouriteButton(button: UIBarButtonItem, programItem: Program) {
        if programItem.attending {
            button.title = "Unfavourite"
        } else {
            button.title = "Favourite"
        }
    }

}

