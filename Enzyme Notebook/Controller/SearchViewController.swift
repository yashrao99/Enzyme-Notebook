//
//  SearchViewController.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/19/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit


class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchGoogle: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var searchArray: [GoogleSearchStruct] = []
    private var cellExpanded: Bool = false
    private var selectedRowIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        searchTextField.placeholder = "Please enter your search query"
        searchTextField.textAlignment = .center
        searchGoogle.isHidden = true
        resultTableView.backgroundColor = UIColor.clear
        searchTextField.delegate = self
        resultTableView.delegate = self
        resultTableView.dataSource = self
        
        let backgroundImg = UIImageView(frame: UIScreen.main.bounds)
        backgroundImg.image = UIImage(named: "RMbg")
        backgroundImg.contentMode = .scaleAspectFill
        self.view.insertSubview(backgroundImg, at: 0)
        
        self.navigationItem.title = "Research"
        
        self.activityIndicator.isHidden = true
        self.activityIndicator.color = UIColor.white
        
    }
    
    @IBAction func googleSearch() {
        
        var parameters = ["q": self.searchTextField.text!, "key": Constants.GoogleSearchAPI.apiKey, "cx":Constants.GoogleSearchAPI.searchID]
        
        let builtURL =  MasterNetwork.sharedInstance().buildURL(parameters)
        
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        if MasterNetwork.sharedInstance().isInternetAvailable() {
            MasterNetwork.sharedInstance().googleSearch(builtURL) { success, searchResults, error in
                if success {
                    self.searchArray = searchResults!
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.resultTableView.reloadData()
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    MasterNetwork.sharedInstance().alertError(self, error: "There is an error with your request. Please try again")
                }
            }
        } else {
            MasterNetwork.sharedInstance().alertError(self, error: "No internet connection available - Please try again when connected")
        }

    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == searchTextField {
           textField.text = ""
           textField.textColor = UIColor.black
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchTextField {
            if !(textField.text?.isEmpty)! || textField.text != "" || textField.text != nil {
                self.searchGoogle.isHidden = false
            }
        }
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! SearchCell
        cell.activityIndicator.startAnimating()
        let info = searchArray[indexPath.row]
        cell.urlLabel.text = info.title
        cell.urlDescription.text = info.htmlSnippet
        cell.backgroundColor? = UIColor.lightGray
        cell.activityIndicator.stopAnimating()
        cell.activityIndicator.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let selectedRow = indexPath.row
            let selectedCell = searchArray[selectedRow]
            if let link = URL(string: selectedCell.urlLink) {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
            }
        }
    }
}
