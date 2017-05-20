//
//  ICloudDriveSupport.swift
//  MoodLog
//
//  Created by Barry Langdon-Lassagne on 5/20/17.
//  Copyright © 2017 Barry A. Langdon-Lassagne. All rights reserved.
//

import UIKit

@objc public class ICloudDriveSupport: NSObject {
    public class func writeToICloudDrive(text: NSAttributedString) {
        let s = text.string
        print(s)
    }
}
