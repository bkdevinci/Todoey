//
//  ViewController.swift
//  Todoey
//
//  Created by Brian Kump on 4/25/18.
//  Copyright © 2018 Brian Kump. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    // Selected category passed in from CategoryViewController
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = selectedCategory?.name
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }


    //MARK: TableView Datasource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error updating done status, \(error)")
            }
            
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    //MARK: Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        // Show UIAlert to get new item from user
        let alert = UIAlertController(title: "Add New Category Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen when user clicks the Add Item button on the alert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item(s), \(error)")
                }

            }
            
            self.tableView.reloadData()
            
            }
            
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create new item"
                textField = alertTextField
            }
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: Model Methods
    
    
    // Accept a specific query request using filtered parameters, or return all Item values if none specified.
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()

    }
    
    
}

//MARK: SearchBar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

    }

    // Monitor for search bar text changes (on main thread) to update View accordingly.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }


    }

}

