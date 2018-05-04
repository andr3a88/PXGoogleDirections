//
//  AppDelegate.swift
//  PXGoogleDirectionsSample
//
//  Created by Romain on 08/03/2015.
//  Copyright (c) 2015 Poulpix. All rights reserved.
//

import UIKit
import PXGoogleDirections
import GoogleMaps
import Droar

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var directionsAPI: PXGoogleDirections!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 15.0)!], for: UIControlState())
		// TODO: For you fellow developer: replace `getGoogleAPI{Client|Server}Key()` in the two lines below with a string containing your own Google Maps API keys!
		GMSServices.provideAPIKey("AIzaSyArog9WTsMi2PvetbUgywIwQ697NwkdKdo") // A valid iOS client-side API key tied to your application's bundle identifier is required here
		directionsAPI = PXGoogleDirections(apiKey: "AIzaSyBSdGUSxB0w9so7HzjdOuyD87EqaGFjCVY") // A valid server-side API key is required here

        Droar.start()

		return true
	}
}
