//
//  LoginViewController.swift
//  Machine_Test_Assignment
//
//  Created by Mr. Raj on 1/2/26.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {


    @IBAction func SignInWithGooglePressed(_ sender: Any) {
        signInWithGoogle()
    }

    func signInWithGoogle() {

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            assertionFailure("Missing Firebase clientID")
            return
        }

        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in

            if let error = error {
                print("Google Sign-In error:", error.localizedDescription)
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                print("Missing Google user or ID token")
                return
            }

            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            // Sign in to Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in failed:", error.localizedDescription)
                    return
                }

                print("Firebase sign-in success")
                print("User ID:", authResult?.user.uid ?? "")
                self.navigateToHome()
            }
        }
    }

    func navigateToHome() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToHome", sender: self)
        }
    }

}

