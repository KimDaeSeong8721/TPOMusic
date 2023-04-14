//
//  AppDelegate.swift
//  TPOMusic
//
//  Created by DaeSeong on 2023/03/09.
//

import AVKit
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        MusicDataManager.shared.setup(modelName: "TPOMusic")
        do {
            // 화면이 꺼져도 음악이 재생되도록
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            // 무음 모드에서도 음악소리
//            try AVAudioSession.sharedInstance().setActive(true)
            } catch {}
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

