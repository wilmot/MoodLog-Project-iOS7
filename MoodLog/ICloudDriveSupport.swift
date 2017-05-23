//
//  ICloudDriveSupport.swift
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/20/17.
//  Copyright © 2017 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit

@objc public class ICloudDriveSupport: NSObject {
    let coordinationQueue: OperationQueue = { // iCloud Support
        let coordinationQueue = OperationQueue()
        coordinationQueue.name = "com.voyageropen.Mood_Log.documentbrowser.coordinationQueue"
        return coordinationQueue
    }()
    
    func presentCloudDisabledAlert() {
        OperationQueue.main.addOperation {
            message(title: "iCloud is disabled", message: "Please enable iCloud Drive in Settings to enable saving files")
        }
    }

    func openDocumentAtURL(_ url: URL) {
        let filename = url.lastPathComponent
        message(title: "File Saved", message: "The file \"\(filename)\" has been saved to iCloud Drive")
    }

    func createiCloudDriveDocumentsDirectory() -> URL? {
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            print("iCloud Documents URL: \(iCloudDocumentsURL)")
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    print("Created directory!")
                } catch let error as NSError {
                    print("Error: \(error)")
                }
            }
            else {
                print("Folder '\(iCloudDocumentsURL.path) exists")
            }
            return iCloudDocumentsURL
        }
        else {
            message(title: "Error fetching URL", message: "Mood-Log was unable to get a URL for the iCloud Documents directory")
        }
        return nil
    }
    
    func writeAttributedString(filename: String, attrString: NSAttributedString) {
        if FileManager().ubiquityIdentityToken == nil {
            message(title: "iCloud Drive is disabled", message: "Please enable iCloud Drive in Settings to save files")
            return
        }
        guard let _ = createiCloudDriveDocumentsDirectory() else {
            message(title: "iCloud Drive error", message: "Couldn't create a 'Documents' directory for Mood-Log on iCloud Drive.")
            return
        }
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("\(filename).rtf")
            let range = NSMakeRange(0, attrString.length)
            let data = try attrString.data(from: range, documentAttributes: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType])
            try data.write(to: fileURL)
            let localDirectoryContents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            print("List of files in local directory:")
            for item in localDirectoryContents {
                print("\t\(item)")
            }
            copyDocumentToiCloud(localFileURL: fileURL, iCloudFilename: filename, fileExtension: "rtf")
        } catch let error as NSError {
            print("Error: \(error)")
            message(title: "Error writing file or moving to iCloud Drive", message: "\(error)")
        }
    }
    
    func copyDocumentToiCloud(localFileURL: URL, iCloudFilename: String, fileExtension: String = "rtf") {
        let filename = iCloudFilename
        /*
         We don't create a new document on the main queue because the call to
         fileManager.URLForUbiquityContainerIdentifier could potentially block
         */
        coordinationQueue.addOperation {
            let fileManager = FileManager()
            guard let baseURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(filename) else {
                self.presentCloudDisabledAlert()
                return
            }
            
            var target = baseURL.appendingPathExtension(fileExtension)
            
            // Append this value to our name until we find a path that doesn't exist.
            var nameSuffix = 2
            
            /*
             Find a suitable filename that doesn't already exist on disk.
             Do not use `fileManager.fileExistsAtPath(target.path!)` because
             the document might not have downloaded yet.
             */
            while (target as NSURL).checkPromisedItemIsReachableAndReturnError(nil) {
                target = URL(fileURLWithPath: baseURL.path + "-\(nameSuffix).\(fileExtension)")
                nameSuffix += 1
            }
            
            // Coordinate reading on the source path and writing on the destination path to copy.
            let readIntent = NSFileAccessIntent.readingIntent(with: localFileURL, options: [])
            let writeIntent = NSFileAccessIntent.writingIntent(with: target, options: .forReplacing)
            
            NSFileCoordinator().coordinate(with: [readIntent, writeIntent], queue: self.coordinationQueue) { error in
                if error != nil {
                    return
                }
                
                do {
                    try fileManager.copyItem(at: readIntent.url, to: writeIntent.url)
                    //try (writeIntent.url as NSURL).setResourceValue(true, forKey: URLResourceKey.hasHiddenExtensionKey)
                    OperationQueue.main.addOperation {
                        // TODO: Delete the local document
                        print("readIntent: \(readIntent)")
                        self.openDocumentAtURL(writeIntent.url)
                    }
                }
                catch {
                    fatalError("Unexpected error during simple file operations: \(error)")
                }
            }
        }
    }
    
    public func writeToICloudDrive(filename: String, text: String) {
        // Convert html stub to attributed string
        let htmlDoc = htmlifyCharacters(string: "<html><body>\(text)</body></html>")
        if let data = htmlDoc.data(using: .utf8) {
            do {
                let attrStr = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
                print(attrStr)
                writeAttributedString(filename: filename, attrString: attrStr)
            }
            catch {
                print("error creating attributed string")
            }
        }
    }
}
