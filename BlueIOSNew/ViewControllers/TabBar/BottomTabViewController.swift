//
//  BottomTabViewController.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import UIKit

class TabViewController: UITabBarController {

    private var aTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aTimer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true){ t in
            if(Settings.initialized) {
                switch (Settings.has_cromo) {
                case 0:
                    self.viewControllers?.remove(at: 1)
                case 2:
                    self.viewControllers?.remove(at: 0)
                default:
                    break
                }
                self.aTimer?.invalidate()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        aTimer?.invalidate()
    }
}
