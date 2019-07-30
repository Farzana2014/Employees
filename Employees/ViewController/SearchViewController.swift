//
//  SecondViewController.swift
//  Employees
//
//  Created by Farzana Sultana on 7/27/19.
//  Copyright © 2019 Farzana Sultana. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var allEmployeeData = [EEmployee]()
    var currentfilteredData = [EEmployee]()
    var fetchOffSet = 0
    
    var dm = DataModel()
    
    @IBOutlet weak var EmployeeListTable: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.allEmployeeData = dm.fetchAllEmployeeData(fetchOffset: 0)
        self.currentfilteredData = self.allEmployeeData
        
        self.EmployeeListTable.rowHeight = UITableView.automaticDimension
        self.EmployeeListTable.estimatedRowHeight = 30
        
        DispatchQueue.main.async {
            self.EmployeeListTable.reloadData()
        }
        setUpSearchBar()
        
        // Do any additional setup after loading the view.
    }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search by Name"
        searchBar.showsCancelButton = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.currentfilteredData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        let currentEmployee = self.currentfilteredData[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        if let employee_name = currentEmployee.employee_name{
            cell.textLabel?.text = employee_name
        }
        
        if let employee_salary = currentEmployee.employee_salary{
            cell.detailTextLabel?.text = employee_salary
        }
        
        return cell
    }
    
    // Search Bar
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.currentfilteredData = self.allEmployeeData.filter({ currentEmployee -> Bool in
            if searchText.isEmpty {return true }
            return currentEmployee.employee_name.lowercased().contains(searchText.lowercased())
        })
        
        DispatchQueue.main.async{
            self.EmployeeListTable.reloadData()
        }    }
    
    
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
                self.EmployeeListTable.reloadData()
            }
        }
    }
}


