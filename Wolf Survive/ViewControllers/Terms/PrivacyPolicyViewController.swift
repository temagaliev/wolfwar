//
//  PrivacyPolicyViewController.swift
//  Wolf Survive
//
//  Created by Artem Galiev on 13.10.2023.
//

import UIKit
import WebKit

class PrivacyPolicyViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: NameImage.backButton.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let url = URL(string: "https://docs.google.com/document/d/1V5TrKmWAYIf-PUHaENdB4cecULDKh5w-1JDLqcuSDTU/edit?usp=sharing")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
        backButton.addTarget(self, action: #selector(onBackButtonClick), for: .touchUpInside)
        
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        backButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
    }
    
    @objc func onBackButtonClick() {
        MainRouter.shared.closeTermsViewScreen()
    }
}
