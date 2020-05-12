//
//  PcapImporter.swift
//  BLE-Scanner
//
//  Created by Alex - SEEMOO on 12.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import UIKit
import BLETools

class PcapImportController: NSObject, ObservableObject, UIDocumentPickerDelegate {
    
    let bleScanner: BLEScanner = Model.bleScanner
    
    override init() {
        print("Initializing import controller")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //Read the external document
        guard let fileURL = urls.first else {return}
        
        //Read the file
        do {
            let data = try Data(contentsOf: fileURL)
            //Import the pcap data
            bleScanner.importPcap(from: data) { (result) in
                switch result {
                case .success(_):
                    NotificationCenter.default.post(name: Notification.Name.App.importingPcapFinished, object: self)
                    break
                case .failure(let pcapError):
                    NotificationCenter.default.post(name: Notification.Name.App.importingPcapFinished, object: self, userInfo: ["error": pcapError])
                    break 
                }
            }
        }catch let error {
            print(error)
        }
        
        
//        let fileCoordinator = NSFileCoordinator()
//        let error: NSErrorPointer
//        fileCoordinator.coordinate(readingItemAt: fileURL, options: .withoutChanges, error: error) { (url) in
//            do {
//                //Read the data
//                let fileData = try Data(contentsOf: url)
//
//            }catch let error {
//
//            }
//        }
    }
    
    func pcapImport() {
        guard let source = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let controller = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .import)
        controller.shouldShowFileExtensions = true
        controller.delegate = self
        
        
        var presentationController = source
        while presentationController.presentedViewController != nil {
            presentationController = presentationController.presentedViewController!
        }
        
        
        controller.popoverPresentationController?.sourceView = presentationController.view
        presentationController.present(controller, animated: true)
    }
}
