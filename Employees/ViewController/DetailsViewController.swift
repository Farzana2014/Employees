//
//  DetailsViewController.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController , UITableViewDelegate, UITableViewDataSource  {

    var allEmployeeData = [EEmployee]()
    var dm = DataModel()
    var fetchOffSet = 0
    
    @IBOutlet weak var employeeListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.employeeListTable.dataSource = self
        self.employeeListTable.delegate = self
        
        // Set automatic dimensions for row height
        self.employeeListTable.rowHeight = UITableView.automaticDimension
        self.employeeListTable.estimatedRowHeight = 30

        loadData()
    }
    

    fileprivate func loadData() {
        // Do any additional setup after loading the view.
        
        self.allEmployeeData = dm.fetchAllEmployeeData(fetchOffset:DATA_FETCH_LIMIT)
            DispatchQueue.main.async{
                self.employeeListTable.reloadData()
            }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        let currentEmployee = self.allEmployeeData[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        if let employee_name = currentEmployee.employee_name{
            cell.textLabel?.text = employee_name
        }
        
        if let employee_salary = currentEmployee.employee_salary{
            cell.detailTextLabel?.text = employee_salary
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
    
    func updateSingleEmployee () {
        
        let employee = self.allEmployeeData.first;
        
        if let employee = employee {
            employee.employee_name  = "\(String(describing: employee.employee_name))-Updated"
            let predicate = NSPredicate(format: "iD=%@", employee.Id)
            let  updated =  dm.modify(employee, entity: "Employee", predicate: predicate, fetchOffset: 0)
            print ("account modified \(updated)")
        } else {
            return
        }
        
    }
    
    // Delete Test
    func DeleteSingleEmployee() {
        
        let employee = self.allEmployeeData.last;
        if let employee = employee {
        let predicate = NSPredicate(format: "iD=%@", employee.Id)
        let  deleted =  dm.deleteData(With: "Employee", predicate: predicate)
        //(employee!, entity: "Employee", predicate: predicate)
            print ("account deleted \(deleted)")
        } else {
            return
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // UITableView only moves in one direction, y axis
        let currentOffset: CGFloat = scrollView.contentOffset.y
        let maximumOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        // Change 50.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 50.0 {
            if self.allEmployeeData.count >= DATA_FETCH_LIMIT {
                fetchOffSet = fetchOffSet + DATA_FETCH_LIMIT
                let array: [EEmployee] = dm.fetchAllEmployeeData(fetchOffset: fetchOffSet)
                
                self.allEmployeeData .append(contentsOf: array)
                self.employeeListTable.reloadData()
            }
        }
    }

    

    @IBAction func addNewEmployee(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: AddEditEmployeeViewController = storyboard.instantiateViewController(withIdentifier: "AddEditEmployeeViewController") as! AddEditEmployeeViewController
        
        let navViewController = self.tabBarController?.selectedViewController as? UINavigationController
        navViewController?.pushViewController(vc, animated: true)
    }
}
