//
//  AddEditEmployeeViewController.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class AddEditEmployeeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameTextFeild: UITextField!
    @IBOutlet var salaryTextFeild: UITextField!
    @IBOutlet var ageTextFeild: UITextField!

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    var currentEmployee = EEmployee()
    var dm = DataModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.view.addGestureRecognizer(tap)
        
        if (currentEmployee != NSNull() && currentEmployee.Id != nil) {
            
            self.saveButtonOutlet.setTitle("Update",for: .normal)
            self.nameTextFeild.text = currentEmployee.employee_name
            self.salaryTextFeild.text = currentEmployee.employee_salary
            self.ageTextFeild.text = currentEmployee.employee_age
            
            
            if let employee_rating = currentEmployee.rating {
                setUPRatingsButtons(tag: Int(employee_rating.intValue))
            }
            
            if let emplyeeimage_url = currentEmployee.profile_image {
                if emplyeeimage_url.count > 0 {
                    loadProfileImage(emplyeeimage_url)
                } else {
                    self.profileImageView.image = UIImage.init(named: "placeholder")
                }
            }
            
        } else {
            self.nameTextFeild.text = ""
            self.salaryTextFeild.text = ""
            self.ageTextFeild.text = ""
            self.saveButtonOutlet.setTitle("Save",for: .normal)
            self.profileImageView.image = UIImage.init(named: "placeholder")
        }
        // Do any additional setup after loading the view.
    }

    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    func setUPRatingsButtons (tag:Int) {
        
        let holderView = self.view.viewWithTag(Int(10))?.viewWithTag(Int(1))
        
        for subview in holderView!.subviews{
            
            if subview.isKind(of: UIButton.self) == true {
                let button = subview as! UIButton
                if button.tag <= tag {
                    button.setImage(UIImage(named: "selected.png"), for: .normal)
                } else{
                    button.setImage(UIImage(named: "deselected.png"), for: .normal)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func saveEmployee(_ sender: Any) {
        
        currentEmployee.employee_name = self.nameTextFeild.text
        currentEmployee.employee_salary = self.salaryTextFeild.text
        currentEmployee.employee_age = self.ageTextFeild.text

        var predicate = NSPredicate()
        
        if let _ = currentEmployee.Id {
            predicate = NSPredicate(format: "iD = %@", currentEmployee.Id)
        } else {
            let timestamp = NSDate().timeIntervalSince1970
            predicate = NSPredicate(format: "iD = %@", String(Int(timestamp)))
            currentEmployee.Id = String(Int(timestamp))
        }
        
        let  updated =  dm.modify(currentEmployee, entity: "Employee", predicate: predicate, fetchOffset: 0)
        
        if updated {
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func ratingButtonClicked(_ sender: UIButton) {
        setUPRatingsButtons(tag: sender.tag)
        currentEmployee.rating = sender.tag as NSNumber
    }
    
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        
        let predicate = NSPredicate(format: "iD=%@", currentEmployee.Id)
        let  deleted =  dm.deleteData(With: "Employee", predicate: predicate)

        if deleted {
            self.navigationController?.popViewController(animated: true)
        }
    }

    fileprivate func loadProfileImage(_ emplyeeimage_url: String) {
        URLSession.shared.dataTask( with: NSURL(string:emplyeeimage_url)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    self.profileImageView.image = UIImage(data: data)
                }
            }
        }).resume()
    }
}
