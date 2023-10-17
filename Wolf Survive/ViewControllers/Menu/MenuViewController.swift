//
//  MenuViewController.swift
//  Wolf Survive
//
//  Created by Artem Galiev on 13.10.2023.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func onPlayButtonClick(_ sender: UIButton) {
        MainRouter.shared.showGameViewScreen()
    }
    
    @IBAction func onTermsButtonClick(_ sender: UIButton) {
        MainRouter.shared.showTermsViewScreen()
    }
}
