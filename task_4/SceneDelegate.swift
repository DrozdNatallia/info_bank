//
//  SceneDelegate.swift
//  task_4
//
//  Created by Natalia Drozd on 27.12.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let viewController = HomeViewController()
        let navigationVC = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
    }
}
