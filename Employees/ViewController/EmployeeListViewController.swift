//
//  FirstViewController.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//  Copyright © 2019 Farzana Sultana. All rights reserved.
//

import UIKit
import CoreData

class EmployeeListViewController: UIViewController, EmployeeListViewModelDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var allEmployeeData = [EEmployee]()
    var allEmployeeDataSorted = [EEmployee]()
    
    var dm = DataModel()
    var fetchOffSet = 0
    
    @IBOutlet weak var employeeListTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.employeeListTable.dataSource = self
        self.employeeListTable.delegate = self
        
        // Set automatic dimensions for row height
        self.employeeListTable.rowHeight = UITableView.automaticDimension
        self.employeeListTable.estimatedRowHeight = 300
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    // MARK: - UITableView delegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat(0)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.01
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.allEmployeeData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let identifier = "EmployeeListCell"
        var cell: EmployeeListCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? EmployeeListCell
        if cell == nil {
            tableView.register(UINib(nibName: "EmployeeListCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? EmployeeListCell
        }
        
        let currentEmployee = self.allEmployeeData[indexPath.row]
        
        if let employee_name = currentEmployee.employee_name{
            cell.nameLabel.text = employee_name
        }
        
        if let employee_age = currentEmployee.employee_age {
            cell.ageLabel.text = employee_age
        }
        
        if let employee_salary = currentEmployee.employee_salary{
            cell.salaryLabel.text = employee_salary
        }
        
        
        if let emplyeeimage_url = currentEmployee.profile_image {
            
            if emplyeeimage_url.count > 0 {
                loadProfileImage(emplyeeimage_url, cell: cell)
            } else {
                cell.profileImage.image = UIImage.init(named: "placeholder")
            }
        } else {
            cell.profileImage.image = UIImage.init(named: "placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: AddEditEmployeeViewController = storyboard.instantiateViewController(withIdentifier: "AddEditEmployeeViewController") as! AddEditEmployeeViewController
        vc.currentEmployee = self.allEmployeeData[indexPath.row]
        
        let navViewController = self.tabBarController?.selectedViewController as? UINavigationController
        navViewController?.pushViewController(vc, animated: true)
        
    }
    

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let maximumOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        // Change 50.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 50.0 {
            if self.allEmployeeData.count >= 100 {
                fetchOffSet = fetchOffSet + 100
                let result: [EEmployee] = dm.fetchAllEmployeeData(fetchOffset: fetchOffSet)
                
                self.allEmployeeData.append(contentsOf: result)
                
                let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
                let sortedResults = (self.allEmployeeData as NSArray).sortedArray(using: [sortDescriptor]) as! [EEmployee]
                self.allEmployeeData = sortedResults
                self.employeeListTable.reloadData()
            }
        }
    }
    // MARK: - API Call
    
    @objc func getEmployeeData(){
        let  viewModel = EmployeeListViewModel()
        viewModel.delegate = self
        viewModel.getEmployeeList()
    }
    
    
    //MARK: - ViewModel delegate
    func modelDidEndGetEmployeeData(_ success: Bool, employees: [EEmployee], errors: [String : String]) {
        
        if success {
            self.allEmployeeData.removeAll()
            self.allEmployeeDataSorted.removeAll()
            
            self.allEmployeeDataSorted = dm.fetchAllEmployeeData(fetchOffset:DATA_FETCH_LIMIT)
            self.allEmployeeData = allEmployeeDataSorted.sorted(by: { $0.rating.intValue > $1.rating.intValue })
            
            DispatchQueue.main.async{
                self.employeeListTable.reloadData()
            }
        }
    }
    
    fileprivate func loadProfileImage(_ emplyeeimage_url: String, cell:EmployeeListCell ) {
        URLSession.shared.dataTask( with: NSURL(string:emplyeeimage_url)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                if let data = data {
                    cell.profileImage.image = UIImage(data: data)
                }
            }
        }).resume()
    }
    
    fileprivate func loadData() {
        // Do any additional setup after loading the view.
        
        let result = dm.fetchAllEmployeeData(fetchOffset:DATA_FETCH_LIMIT)
        let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        let sortedResults = (result as NSArray).sortedArray(using: [sortDescriptor]) as! [EEmployee]
        self.allEmployeeData = sortedResults
        
        if (self.allEmployeeData.count == 0) {
            
            if Reachability.isConnectedToNetwork() == true {
                getEmployeeData()
            } else {
                print("Internet connection FAILED")
                
                let alertController = UIAlertController(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                {
                    (result : UIAlertAction) -> Void in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)

            }
            
        } else {
            DispatchQueue.main.async{
                
                self.employeeListTable.reloadData()
            }
        }
    }
}

