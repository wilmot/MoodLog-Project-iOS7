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
            message(title: NSLocalizedString("iCloud is disabled", comment: "iCloud is disabled - iCloud Drive Support"), message: NSLocalizedString("Please enable iCloud Drive in Settings to enable saving files", comment: "Please enable iCloud Drive in Settings to enable saving files - iCloud Drive Support"))
        }
    }

    func openDocumentAtURL(_ url: URL) {
        let filename = url.lastPathComponent
        message(title: NSLocalizedString("File Saved", comment: "File Saved - iCloud Drive Support"), message: "\n\"\(filename)\"\n\n" + NSLocalizedString("has been saved to iCloud Drive.", comment: "File saved to iCloud Drive - iCloud Drive Support"))
    }

    func createiCloudDriveDocumentsDirectory() -> URL? {
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            dprint("iCloud Documents URL: \(iCloudDocumentsURL)")
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                    dprint("Created new directory")
                } catch let error as NSError {
                    message(title: NSLocalizedString("Error creating iCloud Drive directory", comment: "Error creating iCloud Drive directory - iCloud Drive Support"), message: "\(error)")
                }
            }
            else {
                dprint("Folder '\(iCloudDocumentsURL.path) exists")
            }
            return iCloudDocumentsURL
        }
        else {
            message(title: NSLocalizedString("Error fetching URL", comment: "Error fetching URL - iCloud Drive Support"), message: NSLocalizedString("Mood-Log was unable to get a URL for the iCloud Documents directory", comment: "Mood-Log was unable to get a URL for the iCloud Documents directory - iCloud Drive Support"))
        }
        return nil
    }
    
    func writeAttributedString(filename: String, attrString: NSAttributedString) {
        if FileManager().ubiquityIdentityToken == nil {
            message(title: NSLocalizedString("iCloud Drive is disabled", comment: "iCloud Drive is disabled - iCloud Drive Support"), message: NSLocalizedString("Please enable iCloud Drive in Settings to enable saving files", comment: "Please enable iCloud Drive in Settings to enable saving files - iCloud Drive Support"))
            return
        }
        guard let _ = createiCloudDriveDocumentsDirectory() else {
            message(title: NSLocalizedString("iCloud Drive error", comment: "iCloud Drive error - iCloud Drive Support"), message: NSLocalizedString("Couldn't create a 'Documents' directory for Mood-Log on iCloud Drive.", comment: "Couldn't create a 'Documents' directory for Mood-Log on iCloud Drive - iCloud Drive Support"))
            return
        }
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("\(filename).rtf")
            let range = NSMakeRange(0, attrString.length)
            let data = try attrString.data(from: range, documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf])
            try data.write(to: fileURL)
            let localDirectoryContents = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            dprint("List of files in local directory:")
            for item in localDirectoryContents {
                dprint("\t\(item)")
            }
            copyDocumentToiCloud(localFileURL: fileURL, iCloudFilename: filename, fileExtension: "rtf")
        } catch let error as NSError {
            message(title: NSLocalizedString("Error writing file or moving to iCloud Drive", comment: "Error writing file or moving to iCloud Drive - iCloud Drive Support"), message: "\(error)")
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
                        self.removeLocalFile(url: readIntent.url)
                        dprint("readIntent: \(readIntent)")
                        self.openDocumentAtURL(writeIntent.url)
                    }
                }
                catch {
                    message(title: NSLocalizedString("Error", comment: "Error - iCloud Drive Support"), message: NSLocalizedString("Unexpected error when saving document to iCloud Drive:", comment: "Unexpected error when saving document to iCloud Drive: - iCloud Drive Support") + "\(error)")
                }
            }
        }
    }
    
    func removeLocalFile(url: URL) {
        do  {
            let fileManager = FileManager()
            try fileManager.removeItem(at: url)
        }
        catch {
            message(title: NSLocalizedString("Error", comment: "Error - iCloud Drive Support"), message: NSLocalizedString("Unexpected error when cleaning up", comment: "Unexpected error when cleaning up - iCloud Drive Support"))
        }
    }
    
    @objc public func writeToICloudDrive(filename: String, text: String) {
        // Convert html stub to attributed string
        let htmlDoc = htmlifyCharacters(string: "<html><body>\(text)</body></html>")
        if let data = htmlDoc.data(using: .utf8) {
            do {
                let attrs: [NSAttributedString.DocumentReadingOptionKey: Any] = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                let attrStr = try NSAttributedString(data: data, options: attrs, documentAttributes: nil)
                writeAttributedString(filename: filename, attrString: attrStr)
            }
            catch {
                message(title: NSLocalizedString("Error", comment: "Error - iCloud Drive Support"), message: NSLocalizedString("Error creating attributed string", comment: "Error creating attributed string - iCloud Drive Support"))
            }
        }
    }
}
