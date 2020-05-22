//
//  FileBrowser.swift
//  SignatureSDK-S
//
//  Created by Joss Giffard-Burley on 27/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

import Foundation

enum FSKeys {
    case FILENAME
    case PAT
}

class FileBrowser: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    //==================================================================================================================
    // MARK: Class vars
    //==================================================================================================================
    
    @IBOutlet var cancelButton :UIButton!
    @IBOutlet var okButton :UIButton!
    @IBOutlet var tableView :UITableView!
    @IBOutlet var titleLabel :UILabel!
    @IBOutlet var inputTextField :UITextField!
    @IBOutlet var textFieldUnderline: UIView!
    @IBOutlet var logo: UIImageView!
    
    var selectedFilename :URL?
    var baseDirectory :URL?
    var inputFieldText :String?
    var titleText :String?
    var sourceFile :URL? //used for Open In... requests
    var isOpenDialog :Bool
    var signatureTypesOnly :Bool //Only display .txt, .fss & .png
    
    fileprivate let signatureExts = [ "fss", "png", "txt" ]
    
    fileprivate var directoryIcon = UIImage(named: "action_collection")?.tintedImageWithColour(UIColor(red: 0.121, green: 0.494, blue: 0.807, alpha: 1.0))
    fileprivate var binaryIcon = UIImage(named: "binary_file")?.tintedImageWithColour(UIColor(red: 0.121, green: 0.494, blue: 0.807, alpha: 1.0))
    fileprivate var textIcon = UIImage(named: "text_file")?.tintedImageWithColour(UIColor(red: 0.121, green: 0.494, blue: 0.807, alpha: 1.0))
    fileprivate var imageIcon = UIImage(named: "action_picture")?.tintedImageWithColour(UIColor(red: 0.121, green: 0.494, blue: 0.807, alpha: 1.0))
    fileprivate var currentDirectory :URL?
    
    fileprivate var fileList :[([FileAttributeKey: Any], filename: String, ext: String)] = []
    
    //==================================================================================================================
    // MARK: Init methods
    //==================================================================================================================
    
    required init?(coder aDecoder: NSCoder) {
        isOpenDialog = true
        signatureTypesOnly = false
        super.init(coder: aDecoder)
    }
    
    //==================================================================================================================
    // MARK: UIViewController methods
    //==================================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        okButton.layer.cornerRadius = 5.0
        cancelButton.layer.cornerRadius = 5.0
        tableView.layer.cornerRadius = 3.0
        tableView.layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0).cgColor
        tableView.layer.borderWidth = 1.0
        logo.image = UIImage(named: "logo_window")?.tintedImageWithColour(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.text = titleText
        inputTextField.text = inputFieldText
        currentDirectory = baseDirectory
        tableView.delegate = self
        tableView.dataSource = self
        updateFileList()
    }
    
    //==================================================================================================================
    // MARK: Instance Methods
    //==================================================================================================================
    
    func updateFileList() {
        let fm = FileManager.default
        if let dirEnum = fm.enumerator(atPath: currentDirectory!.path) {
            
            fileList.removeAll(keepingCapacity: false)
            
            while let f :AnyObject = dirEnum.nextObject() as AnyObject? {
                let currentFile :URL = currentDirectory!.appendingPathComponent(f as! String)
                
                //Skip files starting '.' and subpaths
                if f.hasPrefix(".") || f.components(separatedBy: "/").count > 1 {
                    continue
                }
                
                if signatureTypesOnly {
                    if (signatureExts.contains(currentFile.pathExtension.lowercased()) || dirEnum.fileAttributes![FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeDirectory) {
                        let file = dirEnum.fileAttributes!
                        fileList.append((file, currentFile.lastPathComponent, currentFile.lastPathComponent))
                    }
                } else {
                    let file = dirEnum.fileAttributes!
                    fileList.append((file,  currentFile.pathExtension, currentFile.lastPathComponent ))
                }
                
            }
            
            //Sort file list A-Z
            fileList.sort(by: { (a, b) -> Bool in
                let one = a.filename
                let two = b.filename
                return one.compare(two, options:.caseInsensitive, range: nil, locale: nil) == ComparisonResult.orderedAscending
            })
            
            tableView.reloadData()
        }
    }
    
    func dismissKeyboard() {
        inputTextField.resignFirstResponder()
    }
    
    //==================================================================================================================
    // MARK: UITableViewDataSource delegate methods
    //==================================================================================================================
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FILEBROWSER", for: indexPath) 
        let idx = baseDirectory == currentDirectory ? indexPath.row : indexPath.row - 1 //Add .. entry at the top of the list
        let imageExts = ["jpg", "png", "bmp", "gif", "jpg", "jpeg", "tiff"]
        let docExts = ["txt", "doc", "pdf", "docx", "pages"]
     
        
        if(indexPath.row == 0 && currentDirectory != baseDirectory) {
            cell.textLabel!.text = ".."
            cell.accessoryType = .none
            cell.imageView!.image = directoryIcon
        } else {
            var fileDetails = fileList[idx]
           
            if fileDetails.0[FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeDirectory { //Directory
                cell.imageView!.image = directoryIcon
                cell.accessoryType = .disclosureIndicator
            } else if imageExts.contains(fileDetails.ext) { //Image
                cell.imageView!.image = imageIcon
                cell.accessoryType = .none
            } else if docExts.contains(fileDetails.ext) { //Doc
                cell.imageView!.image = textIcon
                cell.accessoryType = .none
            } else {
                cell.imageView!.image = binaryIcon
                cell.accessoryType = .none
            }
            
            cell.textLabel!.text = fileDetails.filename
        }
        
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 16)
        cell.textLabel!.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        
        return cell
    }
    
    //==================================================================================================================
    // MARK: UITableView delegate methods
    //==================================================================================================================
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        
        //Special case for ..
        if (currentDirectory != baseDirectory) && indexPath.row == 0 {
            currentDirectory = currentDirectory?.deletingLastPathComponent()
            updateFileList()
            return
        }
        
        let idx = baseDirectory == currentDirectory ? indexPath.row : indexPath.row - 1 //Add .. entry at the top of the list
        let filename = fileList[idx].filename
        
        //If it is a directory, change to that directory
        if fileList[idx].0[FileAttributeKey.type]! as? FileAttributeType == FileAttributeType.typeDirectory {
            currentDirectory = currentDirectory?.appendingPathComponent(filename)
            updateFileList()
        } else { //Fill in the filename field
            inputTextField.text = filename
            selectedFilename = currentDirectory?.appendingPathComponent(filename)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if baseDirectory == currentDirectory {
            return fileList.count
        } else {
            return fileList.count + 1
        }
    }
    
    //==================================================================================================================
    // MARK: UITextFieldDelegate methods
    //==================================================================================================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Special case for ..
        if currentDirectory != baseDirectory && textField.text == ".." {
            currentDirectory = currentDirectory?.deletingLastPathComponent()
            selectedFilename = nil
            textField.text = nil
            updateFileList()
            return true
        }
        
        var i = 0
        
        for file in fileList {
            if file.filename == textField.text {

                if file.0[FileAttributeKey.type]! as? FileAttributeType == .typeDirectory {
                    currentDirectory = currentDirectory?.appendingPathComponent(textField.text!)
                    selectedFilename = nil
                    textField.text = nil
                    updateFileList()
                } else {
                    tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .top)
                    selectedFilename = currentDirectory?.appendingPathComponent(textField.text!)
                    performSegue(withIdentifier: "UnwindFileOpen", sender: nil)
                }
                return true
            }
            i += 1
        }
        
        //File not found, throw warning and clear entry if open dialog
        if isOpenDialog {
            let av = UIAlertController(title: "Error", message: "File not found:\(String(describing: textField.text))", preferredStyle: .alert)
            av.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            dismiss(animated: false, completion: nil)
            present(av, animated: true, completion: nil)
            updateFileList()
        } else {
            selectedFilename = currentDirectory?.appendingPathComponent(textField.text!)
            performSegue(withIdentifier: "UnwindFileOpen", sender: nil)
        }
        
        return true
    }
    
    //==================================================================================================================
    // MARK: Navigation methods
    //==================================================================================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let textPath = currentDirectory?.appendingPathComponent(inputTextField.text!)
        
        if(selectedFilename == nil || selectedFilename != textPath) {
            selectedFilename = textPath
        }
    }
}
