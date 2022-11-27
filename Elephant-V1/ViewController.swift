//
//  ViewController.swift
//  Elephant-V1
//
//  Created by Lionel Yu on 11/17/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var itemShow: UITableView!
    @IBOutlet weak var projectDropdown: UIPickerView!
    
    @IBOutlet weak var itemTextView: UITextField!
    @IBOutlet weak var projectTextView: UITextField!
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ActiveItems.plist")
    let inactiveFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("InactiveItems.plist")
    let saveFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SavedItems.plist")
    let projectsFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Projects.plist")
    
    var numItemsShown = 1
    
    var filteredArray: [Item] = []
//    var activeArray: [Item] = []
//    var inactiveArray: [Item] = []
    var filteredActiveArray: [Item] = []
    var filteredInactiveArray: [Item] = []
    
    var checkCategory: String = ""
    var dictPriority = [
        "Game":1,
        "Piano":1,
        "Cleaning":3,
        "None":0
    ]
    var allCategories: [String] = []
    var uniqueAllCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemShow.delegate = self
        itemShow.dataSource = self
        
        projectDropdown.delegate = self
        projectDropdown.dataSource = self

//        Model.shared.itemArray = [
//            Item(title: "First Item", done: false, catego: "None", uniqueNum: 1, status: "Active"),
//            Item(title: "Second Item", done: true, catego: "None", uniqueNum: 2, status: "Active"),
//            Item(title: "Third Item", done: true, catego: "None", uniqueNum: 3, status: "Active"),
//            Item(title: "Fourth Item", done: true, catego: "None", uniqueNum: 4, status: "Active"),
//            Item(title: "Fifth Item", done: true, catego: "None", uniqueNum: 5, status: "Active"),
//            Item(title: "Sixth Item", done: true, catego: "None", uniqueNum: 6, status: "Active"),
//            Item(title: "Seventh Item", done: true, catego: "None", uniqueNum: 7, status: "Active"),
//            Item(title: "Eighth Item", done: true, catego: "None", uniqueNum: 8, status: "Active"),
//            Item(title: "Nineth Item", done: true, catego: "None", uniqueNum: 9, status: "Active")
//        ]
//
//        Model.shared.inactiveArray = [
//            Item(title: "Tenth Item", done: true, catego: "None", uniqueNum: 10, status: "Inact"),
//            Item(title: "Eleventh Item", done: true, catego: "None", uniqueNum: 11, status: "Inact"),
//            Item(title: "Twelveth Item", done: true, catego: "Piano", uniqueNum: 12, status: "Inact"),
//            Item(title: "Thirteenth Item", done: true, catego: "None", uniqueNum: 13, status: "Inact"),
//            Item(title: "Fourteenth Item", done: true, catego: "Piano", uniqueNum: 14, status: "Inact"),
//            Item(title: "Fifteenth Item", done: true, catego: "Piano", uniqueNum: 15, status: "Inact")
//        ]
//
//        Model.shared.projectArray = [
//            Project(name: "None", completed: false, priority: 100000),
//            Project(name: "Piano", completed: false, priority: 3),
//            Project(name: "Cleaning", completed: false, priority: 3)
//        ]
        self.loadItems()
        
        Model.shared.uniqueNumCounter = Model.shared.itemArray.count + Model.shared.inactiveArray.count + Model.shared.savedItems.count
        
        for item in Model.shared.projectArray {
            uniqueAllCategories.append(item.name)
        }
    }
    
    
    
    
    
    
//MARK: PICKER VIEW METHODS
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return Model.shared.projectArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return Model.shared.projectArray[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.projectTextView.text = Model.shared.projectArray[row].name
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.projectTextView {
            self.projectDropdown.isHidden = false
            textField.endEditing(true)
        }
    }
    
    
    
    
    
    
    
    
    
    
//MARK: - TABLE VIEW METHODS

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numItemsShown
//        return Model.shared.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemShow.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
//        let tempReverse = Array(Model.shared.itemArray.reversed())
//        cell.textLabel?.text = tempReverse[indexPath.row].title
        
        cell.textLabel?.text = Model.shared.itemArray[indexPath.row].title
        cell.detailTextLabel?.text = Model.shared.itemArray[indexPath.row].catego
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .byWordWrapping;
        if Model.shared.itemArray[indexPath.row].status == "Active" {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var textField = UITextField()
//        let testVar2 = searchIndex(name: filteredArray[indexPath.row].uniqueNum, searchArray: Model.shared.theArray)
        let alert = UIAlertController(title: "Edit Current Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Edit This Item", style: .default) { (action) in
            var newItem = Model.shared.itemArray[indexPath.row]
            newItem.title = textField.text!

            Model.shared.itemArray[indexPath.row] = newItem
            self.saveItems()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = Model.shared.itemArray[indexPath.row].title
            textField = alertTextField
        }
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
//MARK: Navigation Button Items
    
    
    @IBAction func addItemNavPressed(_ sender: UIBarButtonItem) {
        Model.shared.uniqueNumCounter += 1
        var tempCatego = self.projectTextView.text!
        var anotherValue = ""
        if tempCatego == "" {
            anotherValue = "None"
        } else {
            anotherValue = self.projectTextView.text!
        }
        print(anotherValue)
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Item With None Project", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item With None Project", style: .default) { (action) in
            
            let tempTitle = textField.text!
            let newItem = Item(
                title: tempTitle,
                done: false,
                catego: anotherValue,
                uniqueNum: Model.shared.uniqueNumCounter,
                status: "Inact")
            
            Model.shared.inactiveArray.append(newItem)
            self.saveItems()
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
        
        present(alert, animated: true, completion: {
            let alert2 = UIAlertController(title: "Alert", message: "Data has been updated", preferredStyle: UIAlertController.Style.alert)
            alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert2, animated: true, completion: nil)
        })

        
        
        
    }
    
    
    
    
    
//MARK: Top 3 Buttons
    
    @IBAction func completeItemPressed(_ sender: UIButton) {
        
        switch numItemsShown {
        case 1:
            Model.shared.itemArray[0].status = "Done"
            Model.shared.savedItems.append(Model.shared.itemArray[0])
            Model.shared.itemArray.remove(at: 0)
        case 2:
            Model.shared.itemArray[1].status = "Done"
            Model.shared.savedItems.append(Model.shared.itemArray[1])
            Model.shared.itemArray.remove(at: 1)
        case 3:
            Model.shared.itemArray[2].status = "Done"
            Model.shared.savedItems.append(Model.shared.itemArray[2])
            Model.shared.itemArray.remove(at: 2)
        default:
            print("Something's wrong, check CompleteItemPressed")
        }
          
        if Model.shared.itemArray.count == 0 {
            let newItem = Item(
                title: "No Items",
                done: false,
                catego: "None",
                uniqueNum: 999999,
                status: "Active")
            Model.shared.itemArray.append(newItem)
            saveItems()
        } else {
            saveItems()
        }
        
        checkOtherCategories()
        
        let alert = UIAlertController(title: "Task Completed.", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    
    @IBAction func completeDupePressed(_ sender: UIButton) {
        Model.shared.uniqueNumCounter += 1
        var tempTitle = ""
        var tempCatego = ""
        
        switch numItemsShown {
        case 1:
            tempTitle = Model.shared.itemArray[0].title
            tempCatego = Model.shared.itemArray[0].catego
            Model.shared.itemArray[0].status = "Done"
            Model.shared.savedItems.append(Model.shared.itemArray[0])
            Model.shared.itemArray.remove(at: 0)
        case 2:
            tempTitle = Model.shared.itemArray[1].title
            tempCatego = Model.shared.itemArray[1].catego
            Model.shared.itemArray[1].status = "Done"
            Model.shared.savedItems.append(Model.shared.itemArray[1])
            Model.shared.itemArray.remove(at: 1)
        default:
            print("Something's wrong, check DuplicateItemsPressed")
        }
        
        let newItem = Item(
            title: tempTitle,
            done: false,
            catego: tempCatego,
            uniqueNum: Model.shared.uniqueNumCounter,
            status: "Active"
        )
        
        Model.shared.itemArray.append(newItem)
        saveItems()
        
        let alert = UIAlertController(title: "Task Completed and Duplicated.", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: BACKUP PLIST FILES
    @IBAction func backupPlistFiles(_ sender: UIButton) {
        let dateVar = Date.now.formatted(date: .abbreviated, time: .standard)
        let docuDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let musicDir = FileManager.default.urls(for: .musicDirectory, in: .allDomainsMask).first
        
        let d = musicDir!.path + "/" + dateVar
        do {
            try FileManager.default.createDirectory(atPath: d, withIntermediateDirectories: true, attributes: nil)
            print("Folder created \(d)")
        } catch (let error) {
            print("SHITS FUCKED")
        }
        
        let musicDestURL = URL(fileURLWithPath: d)
        
        
        let pListArray = ["/ActiveItems.plist",
                          "/InactiveItems.plist",
                          "/SavedItems.plist",
                          "/Projects.plist"
        ]
        
        for eachFile in pListArray {
            let bbag = docuDir!.path + "/" + eachFile
            let bbagDest = URL(fileURLWithPath: bbag)
            let dbag = musicDir!.path + "/" + dateVar + eachFile
            let dbagDest = URL(fileURLWithPath: dbag)
            self.secureCopyItem(at: bbagDest, to: dbagDest)
            
        }
        
        let alert = UIAlertController(title: "Files Saved.", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            alert.dismiss(animated: true, completion: nil)
        })

        
        
    }
    
    
    
    
    
    
    
    

    
    
    
    
    
    
//MARK: Bottom 3 Buttons
    
    @IBAction func addItemPressed(_ sender: UIButton) {
        Model.shared.uniqueNumCounter += 1
        
//        var tempTitle = self.itemTextView.text!
        var tempCatego = self.projectTextView.text!
        
        var anotherValue = ""
        
        if tempCatego == "" {
            anotherValue = "None"
        } else {
            anotherValue = self.projectTextView.text!
        }
        print(anotherValue)
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Item With None Project", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item With None Project", style: .default) { (action) in
            
            
//            Model.shared.uniqueNumCounter += 1
            let tempTitle = textField.text!
            let newItem = Item(
                title: tempTitle,
                done: false,
                catego: anotherValue,
                uniqueNum: Model.shared.uniqueNumCounter,
                status: "Inact")
            
            Model.shared.inactiveArray.append(newItem)
            self.saveItems()
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
        
        present(alert, animated: true, completion: {
            let alert2 = UIAlertController(title: "Alert", message: "Data has been updated", preferredStyle: UIAlertController.Style.alert)
            alert2.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert2, animated: true, completion: nil)
        })
            
        
        
        
//
//        let newItem = Item(
//            title: self.itemTextView.text!,
//            done: false,
//            catego: anotherValue,
//            uniqueNum: Model.shared.uniqueNumCounter,
//            status: "Inact"
//        )
//        Model.shared.inactiveArray.append(newItem)
//        self.saveItems()
//

        self.itemTextView.text = ""
//        let alert2 = UIAlertController(title: "Item Added.", message: "", preferredStyle: .alert)
//        present(alert2, animated: true, completion: nil)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//            alert2.dismiss(animated: true, completion: nil)
//        })
    }
    
    
    
    @IBAction func undoAddPressed(_ sender: UIButton) {
        var currentCount = Model.shared.inactiveArray.count - 1
        self.itemTextView.text = ""
        print(Model.shared.inactiveArray[currentCount])
        
        Model.shared.inactiveArray.remove(at: currentCount)
        currentCount = Model.shared.inactiveArray.count - 1
        print(Model.shared.inactiveArray[currentCount])
        self.saveItems()
        Model.shared.uniqueNumCounter -= 1
        print(Model.shared.uniqueNumCounter)
        let alert = UIAlertController(title: "Last File Added Removed.", message: "", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            alert.dismiss(animated: true, completion: nil)
        })
        
    }
    
    
    
    
    @IBAction func viewProjectsPressed(_ sender: UIButton) {
    }
    
    @IBAction func showTwoItemsPressed(_ sender: UIButton) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Choose Number Of Items Shown", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Choose Number Of Items Shown", style: .default) { (action) in
            
            
            let numItemsSelected = textField.text!
            let intNumItemsSelected = Int(numItemsSelected)
            self.numItemsShown = intNumItemsSelected!
            self.itemShow.reloadData()
        }

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter Integer"
            textField = alertTextField
        }
        alert.addAction(action)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            print("Cancelled")
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
//        if numItemsShown == 1 {
//            numItemsShown = 2
//            self.itemShow.reloadData()
//        } else {
//            numItemsShown = 1
//            self.itemShow.reloadData()
//        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//MARK: special functions
    func searchIndex(name: Int, searchArray: [Item]) -> Int? {
      return searchArray.firstIndex { $0.uniqueNum == name }
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do{
                Model.shared.itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("error decoding")
            }
        }
        
        if let data = try? Data(contentsOf: inactiveFilePath!) {
            let decoder = PropertyListDecoder()
            do{
                Model.shared.inactiveArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("error decoding")
            }
        }
        
        if let data = try? Data(contentsOf: saveFilePath!) {
            let decoder = PropertyListDecoder()
            do{
                Model.shared.savedItems = try decoder.decode([Item].self, from: data)
            } catch {
                print("error decoding")
            }
        }
        
        if let data = try? Data(contentsOf: projectsFilePath!) {
            let decoder = PropertyListDecoder()
            do{
                Model.shared.projectArray = try decoder.decode([Project].self, from: data)
            } catch {
                print("error decoding")
            }
        }
        
        if Model.shared.itemArray.count == 0 {
            let newItem = Item(title: "Placeholder", done: true, catego: "None", uniqueNum: 99999, status: "Active")
            Model.shared.itemArray.append(newItem)
        } else {
            saveItems()
        }
    }
    
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
        
        self.itemShow.reloadData()
        self.projectDropdown.reloadAllComponents()
    }
    
    
//MARK: LOGIC FOR PROJECT CONTINUATION
    func checkOtherCategories(){
        uniqueAllCategories = []
        for item in Model.shared.projectArray {
            uniqueAllCategories.append(item.name)
        }
        for cat in uniqueAllCategories {
            filteredActiveArray = Model.shared.itemArray.filter({ $0.catego == cat})
            filteredInactiveArray = Model.shared.inactiveArray.filter({ $0.catego == cat})
            
            let tempIndex = Model.shared.projectArray.firstIndex { $0.name == cat}
            let tempPriority = Model.shared.projectArray[Int(tempIndex!)].priority
            let tempName = Model.shared.projectArray[Int(tempIndex!)].name

            var indexHighest: Float = 0
            if filteredActiveArray.count == 0 {
                let levelCheck = 0
            } else {
                let levelCheck = Model.shared.itemArray.firstIndex { $0.catego == cat }
                indexHighest = Float(levelCheck!)
//                print("the indexHighest for \(cat) is \(indexHighest)")
            }
            var level = (Float(Model.shared.itemArray.count) / Float(tempPriority)) * Float(filteredActiveArray.count)
            var finalLevel = Float(Model.shared.itemArray.count) - level
            
//            print("the final level for \(cat) is \(finalLevel)")
            if filteredActiveArray.count >= tempPriority || filteredInactiveArray.count == 0 || indexHighest >= finalLevel {
                print("Nothing was added for \(cat) with priority \(tempPriority)")
            } else {
                var tempItem = filteredInactiveArray[0]
                var tempNum = tempItem.uniqueNum
                var tempIndex = Model.shared.inactiveArray.firstIndex { $0.uniqueNum == tempNum }
                
                print(tempIndex)
                Model.shared.inactiveArray[tempIndex!].status = "Active"
                var itemAdded = Model.shared.inactiveArray[tempIndex!]
//                activeArray = itemArray.filter({ $0.status == "Active"})
                Model.shared.itemArray.append(itemAdded)
                Model.shared.inactiveArray.remove(at: tempIndex!)
                print("we added item \(itemAdded.title) from project \(cat) with priority \(tempPriority)")
            }
        }
        saveItems()
        self.itemShow.reloadData()
    }
    
    
    
    
//MARK: COPY ITEMS FUNCTION
    open func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        do {
            if FileManager.default.fileExists(atPath: dstURL.path) {
                try FileManager.default.removeItem(at: dstURL)
            }
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    

}

