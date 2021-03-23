//
//  signUpViewController.swift
//  lineChat
//
//  Created by 岩佐力 on 2021/03/16.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseStorage
import PKHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    
    
    @IBAction func tappendRegisterButton(_ sender: Any) {
        
        let image = profileImageButton.imageView?.image ?? UIImage(named: "Unknown")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else { return  }
        
        HUD.show(.progress)
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) {(mata, err) in
            if let err = err {
                print("S失敗しました\(err)")
                HUD.hide()
                return
            }
            print("S成功しました")
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("DL失敗しました\(err)")
                    HUD.hide()
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                print("DL成功しました")
                self.createUserToFierstore(profileImageUrl: urlString)
            }
        }
        
    }
    
    private func createUserToFierstore(profileImageUrl: String) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return  }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if  let err = err {
                print("情報の登録に失敗しました \(err)")
                HUD.hide()
                return
            }
            
            print("成功")
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            let docData = [
                "email": email,
                "username": username,
                "cretentAt": Timestamp(),
                "profileImageUrl": profileImageUrl
            ] as [String : Any]
            
            
            Firestore.firestore().collection("users").document(uid).setData(docData) {
                (err) in
                if let err = err {
                    print("DB失敗しました\(err)")
                    HUD.hide()
                    return
                }
                
                print("DB成功しました。")
                HUD.hide()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    
    private func setupViews() {
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        registerButton.layer.cornerRadius = 12
        registerButton.isEnabled = false
        registerButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedalreadyHaveAccountButton), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
    }
    
    @objc private func tappedalreadyHaveAccountButton() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        dismiss(animated: true, completion: nil)
        
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        }
    }
    
    
    
}
