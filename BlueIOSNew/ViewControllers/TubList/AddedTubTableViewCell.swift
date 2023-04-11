//
//  AddedTubTableViewCell.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation
import UIKit
import DCKit

class AddedTubTableViewCell: UITableViewCell {
    @IBOutlet weak var tubname_txt: UILabel!
    @IBOutlet weak var ble_ico: UIImageView!
    @IBOutlet weak var wifi_ico: UIImageView!
    @IBOutlet weak var mqtt_ico: UIImageView!
    @IBOutlet weak var delete_btn: UIButton!
    @IBOutlet weak var back_card: DCBorderedView!
}
