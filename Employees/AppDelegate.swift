//
//  AppDelegate.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//  Copyright © 2019 Farzana Sultana. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, EmployeeListViewModelDelegate {

    var window: UIWindow?

    var managedObjectContext : NSManagedObjectContext?
    var managedObjectModel : NSManagedObjectModel?
    var persistentStoreCoordinator : NSPersistentStoreCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        if DB_UPDATED == false {
//            getEmployeeData()
//            DB_UPDATED = true
//        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @objc func getEmployeeData(){
        
        let  viewModel = EmployeeListViewModel()
        viewModel.delegate = self
        viewModel.getEmployeeList()
        
    }
    
    //MARK: - ViewModel delegate
    func modelDidEndGetEmployeeData(_ success: Bool, employees: [EEmployee], errors: [String : String]) {
        
        
        print(employees)
        //        closeLoadingView()
        
        if success {
            //            if Utility.isProfileCompleted() {
            //                ViewManager.navigate(From: self, To: DashboardVC, data: nil)
            //            } else {
            //                ViewManager.navigate(From: self, To: ProfileSetUpVC, data: nil)
            //            }
        } else {
            _ = false
            
            //            for (k,v) in errors{
            //
            //                if k ==  "Email"{
            //                    emailTextField.showErrorMsg(msg: v)
            //                    containFieldError = true
            //                }
            //                else if k ==  "Password"{
            //                    passwordTextField.showErrorMsg(msg: v)
            //                    containFieldError = true
            //                }
            //            }
            //
            //            if !containFieldError && errors.keys.count > 0{
            //                Utility.showErrorAlert(errors: errors as AnyObject)
            //            }
            
        }
    }
}

