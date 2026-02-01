//
//  SceneDelegate.swift
//  Machine_Test_Assignment
//
//  Created by Mr. Raj on 1/2/26.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)

        if Auth.auth().currentUser != nil {
            if NetworkMonitor.shared.isConnected {
                showHome()
            } else {
                forceLogout()
            }        } else {
            showLogin()
        }
        window?.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        GIDSignIn.sharedInstance.handle(url)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func forceLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Sign out error:", error.localizedDescription)
        }
        showLogin()
    }
    
    func showHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeTableViewController")
        let nav = UINavigationController(rootViewController: homeVC)
        window?.rootViewController = nav
    }

    func showLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController")
        let nav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = nav
    }

}

