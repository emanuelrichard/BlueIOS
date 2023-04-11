//
//  ATubViewCell.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation
import UIKit
import DCKit

class ATubViewCell: UICollectionViewCell {
    @IBOutlet weak var tubname_txt: UILabel!
    @IBOutlet weak var fav_btn: UIButton!
    @IBOutlet weak var conn_btn: UIButton!
    @IBOutlet weak var del_btn: UIButton!
    @IBOutlet weak var conn_viw: DCBorderedView!
    @IBOutlet weak var conn_hgt: NSLayoutConstraint!
    @IBOutlet weak var ble_ico: UIButton!
    @IBOutlet weak var wifi_ico: UIButton!
    @IBOutlet weak var mqtt_ico: UIButton!
}
