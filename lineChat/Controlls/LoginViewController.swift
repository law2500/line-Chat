//
//  LoginViewController.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/21.
//

import UIKit
import FirebaseAuth
import Firebase
import PKHUD


class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
        dontHaveAccoutButton.addTarget(self, action: #selector(tappedDontHaveAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(tappndLoginButton), for: .touchUpInside)
    }
    
    @objc private func tappedDontHaveAccountButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func tappndLoginButton() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        HUD.show(.progress)
        
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("サイン失敗しました\(err)")
                HUD.hide()
                return
        }
            HUD.hide()
            print("サイン成功しました")
            
            let nav = self.presentingViewController as! UINavigationController
            let chatListViewController = nav.viewControllers[nav.viewControllers.count-1] as? ChatListViewController
            chatListViewController?.fetchChatroomsInfoFromFierstire()
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
