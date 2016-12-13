//
//  AKExtensions.swift
//  Akedo
//
//  Created by Seth on 2016-09-14.
//

import Cocoa

extension FileManager {
    /// Returns the size of all the passed files combined, in megabytes
    func sizeOfFiles(_ filePaths : [String]) -> Float {
        /// The size to return
        var size : Float = 0;
        
        // For every passed file...
        for(_, currentFile) in filePaths.enumerated() {
            do {
                /// The size of this file in megabytes
                let fileSize : Float = Float(try (FileManager.default.attributesOfItem(atPath: currentFile)[FileAttributeKey.size]! as AnyObject).int64Value) / Float(1000000);
                
                // Add the current file's size to size
                size += fileSize;
            }
            catch let error as NSError {
                print("NSFileManager: Error getting size of \"\(currentFile)\", \(error.description)");
            }
        }
        
        // Return size
        return size;
    }
}
