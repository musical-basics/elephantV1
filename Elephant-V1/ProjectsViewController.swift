//
//  ProjectsViewController.swift
//  Elephant-V1
//
//  Created by Lionel Yu on 11/18/22.
//

import UIKit

class ProjectsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var projectDropdown: UIPickerView!
    @IBOutlet weak var projectItemsTable: UITableView!
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ActiveItems.plist")
    let inactiveFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("InactiveItems.plist")
    let saveFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SavedItems.plist")
    let projectsFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Projects.plist")
    
    var itemArray: [Item] = []
    var savedItems: [Item] = []
    var categoSelected = ""
    var filteredArray: [Item] = []
    var filteredInactiveArray: [Item] = []
    
    var removeNoneProjects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        projectDropdown.delegate = self
        projectDropdown.dataSource = self
        
        projectItemsTable.delegate = self
        projectItemsTable.dataSource = self
        
//        categoSelected = "None"
//        
//        filteredArray = Model.shared.itemArray.filter({ $0.catego == "None"})
//        filteredInactiveArray = Model.shared.inactiveArray.filter({ $0.catego == "None"})
//        filteredArray = filteredArray + filteredInactiveArray
        
        removeNoneProjects = Model.shared.projectArray.filter({ $0.name != "None"})
        
        self.projectItemsTable.reloadData()
    }
    
//MARK: PICKER VIEW METHODS
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return removeNoneProjects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return removeNoneProjects[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.categoryTextField.text = Model.shared.projectArray[row].name
//        categoSelected = Model.shared.projectArray[row].name
        categoSelected = removeNoneProjects[row].name
        
        filteredArray = Model.shared.itemArray.filter({ $0.catego == categoSelected})
        filteredInactiveArray = Model.shared.inactiveArray.filter({ $0.catego == categoSelected})
        filteredArray = filteredArray + filteredInactiveArray
        self.projectItemsTable.reloadData()
    }

//MARK: TABLE VIEW METHODS

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        removeNoneProjects = filteredArray.filter({ $0.catego != "None"})
        return filteredArray.count
//        return Model.shared.itemArray.count
//        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = projectItemsTable.dequeueReusableCell(withIdentifier: "projectItems", for: indexPath)
        cell.textLabel?.text = filteredArray[indexPath.row].title
        if filteredArray[indexPath.row].status == "Active" {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var textField = UITextField()
        let alert = UIAlertController(title: "Edit Current Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Edit This Item", style: .default) { (action) in
            
            var newItem = self.filteredArray[indexPath.row]
            newItem.title = textField.text!
            self.filteredArray[indexPath.row] = newItem
            
            var indexSelected = Model.shared.inactiveArray.firstIndex { $0.uniqueNum == newItem.uniqueNum}
            Model.shared.inactiveArray[Int(indexSelected!)] = newItem
            self.saveItems()
//            self.filteredArray = Model.shared.itemArray.filter{ $0.catego == self.categoSelected}
            self.projectItemsTable.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = self.filteredArray[indexPath.row].title
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    

    
    
//MARK: ADD FUNCTIONS HERE
    
    @IBAction func addProjectPressed(_ sender: UIButton) {
        // Create alert controller
        let alertController = UIAlertController(title: "Add New Project", message: "Begin an empty project here.", preferredStyle: .alert)

        // add textfield at index 0
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "Project Name"
        })

        // add textfield at index 1
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "What is the Priority (1-5)"
        })

        // Alert action confirm
        let confirmAction = UIAlertAction(title: "Add Project", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
            var tempName = alertController.textFields?[0].text
            var tempPriority = alertController.textFields?[1].text
            var tempProject = Project(
                name: tempName!,
                completed: false,
                priority: Int(tempPriority!)!
                )
            Model.shared.projectArray.append(tempProject)
            self.removeNoneProjects.append(tempProject)
            self.saveItems()
            
            self.projectDropdown.reloadAllComponents()
            
            
        })
        alertController.addAction(confirmAction)
        
        // Alert action cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alertController.addAction(cancelAction)

        // Present alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func editPriority(_ sender: UIButton) {
        // Create alert controller
        let alertController = UIAlertController(title: "Edit Priority", message: "Please enter new priority.", preferredStyle: .alert)

        // add textfield at index 0
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            
            var newItem = self.categoSelected
            var projectIndex = Model.shared.projectArray.firstIndex { $0.name == newItem}
            var currentPriority = Model.shared.projectArray[projectIndex!].priority
            textField.placeholder = "Current Priority is \(currentPriority)"
        })

        // Alert action confirm
        let confirmAction = UIAlertAction(title: "Edit Priority", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
            var newItem = self.categoSelected
            var projectIndex = Model.shared.projectArray.firstIndex { $0.name == newItem}
            
            var tempPriority = alertController.textFields?[0].text
            Model.shared.projectArray[projectIndex!].priority = Int(tempPriority!)!
            print(Model.shared.projectArray[projectIndex!].priority)
            self.saveItems()
            self.projectDropdown.reloadAllComponents()
        })
        alertController.addAction(confirmAction)
        
        // Alert action cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alertController.addAction(cancelAction)

        // Present alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func addItemProj(_ sender: UIButton) {
        
        var textField = UITextField()
//        let testVar2 = searchIndex(name: filteredArray[indexPath.row].uniqueNum, searchArray: Model.shared.theArray)
        let alert = UIAlertController(title: "Add Item To This Project", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item To This Project", style: .default) { (action) in
            
            Model.shared.uniqueNumCounter += 1
            let tempTitle = textField.text!
            var newItem = Item(
                title: tempTitle,
                done: false,
                catego: self.categoSelected,
                uniqueNum: Model.shared.uniqueNumCounter,
                status: "Inact")
            
            Model.shared.inactiveArray.append(newItem)
            self.filteredArray = Model.shared.itemArray.filter{ $0.catego == self.categoSelected} + Model.shared.inactiveArray.filter{ $0.catego == self.categoSelected}
            self.saveItems()
            self.projectItemsTable.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add Item Here"
            textField = alertTextField
        }
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
//MARK: Special Functions
//
//    func loadItems() {
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do{
//                Model.shared.itemArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("error decoding")
//            }
//        }
//
//        if let data = try? Data(contentsOf: inactiveFilePath!) {
//            let decoder = PropertyListDecoder()
//            do{
//                Model.shared.inactiveArray = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("error decoding")
//            }
//        }
//
//        if let data = try? Data(contentsOf: saveFilePath!) {
//            let decoder = PropertyListDecoder()
//            do{
//                Model.shared.savedItems = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("error decoding")
//            }
//        }
//
//        if let data = try? Data(contentsOf: projectsFilePath!) {
//            let decoder = PropertyListDecoder()
//            do{
//                Model.shared.projectArray = try decoder.decode([Project].self, from: data)
//            } catch {
//                print("error decoding")
//            }
//        }
//
//        if Model.shared.itemArray.count == 0 {
//            let newItem = Item(title: "Placeholder", done: true, catego: "None", uniqueNum: 99999, status: "Active")
//            Model.shared.itemArray.append(newItem)
//        } else {
//            saveItems()
//        }
//    }
    
    //MARK: SAVED ITEMS
    func saveItems() {
        let encoder = PropertyListEncoder()
        do{
            let data = try encoder.encode(Model.shared.itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("error encoding item array")
        }
        
        do{
            let data = try encoder.encode(Model.shared.inactiveArray)
            try data.write(to: inactiveFilePath!)
        } catch {
            print("error encoding item array")
        }

        do{
            let data = try encoder.encode(Model.shared.savedItems)
            try data.write(to: saveFilePath!)
        } catch {
            print("error encoding item array")
        }
        
        do{
            let data = try encoder.encode(Model.shared.projectArray)
            try data.write(to: projectsFilePath!)
        } catch {
            print("error encoding item array")
        }
        
//        self.projectItemsTable.reloadData()
    }
    
    
    
}
