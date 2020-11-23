//
//  BookCellTableViewCell.swift
//  CSCI321_Assign6
//
//  Created by Rutvik Patel on 11/22/20.
//  Copyright © 2020 Rut Codes. All rights reserved.
//

import UIKit

class BookCell: UITableViewCell {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
