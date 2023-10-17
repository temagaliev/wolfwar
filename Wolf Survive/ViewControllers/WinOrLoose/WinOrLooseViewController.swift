//
//  WinOrLooseViewController.swift
//  Wolf Survive
//
//  Created by Artem Galiev on 13.10.2023.
//

import UIKit

class WinOrLooseViewController: UIViewController {
    
    @IBOutlet weak var resultView: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var bestResultLabel: UILabel!
    
    var isWin: Bool
    var level: Int
    var starValue: Int
    
    init(isWin: Bool, level: Int, starValue: Int) {
        self.isWin = isWin
        self.level = level
        self.starValue = starValue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch isWin {
        case true:
            resultView.image = UIImage(named: NameImage.winView.rawValue)
            scoreLabel.text = "Score - \(starValue)"
            bestResultLabel.text = "Best - \(Int.random(in: (starValue + 1)...(starValue + 20)))"
        case false:
            resultView.image = UIImage(named: NameImage.loseView.rawValue)
            scoreLabel.text = "You level - \(level)"
            bestResultLabel.text = "Best level - \(132)"
        }
    }
    
    @IBAction func onMenuButtonClick(_ sender: UIButton) {
        MainRouter.shared.showMenuViewScreen()
    }
    
    @IBAction func onReplayButtonClick(_ sender: UIButton) {
        MainRouter.shared.closeWinViewScreen()
    }
}
