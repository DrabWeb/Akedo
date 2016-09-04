//
//  AKPomf.swift
//  Akedo
//
//  Created by Seth on 2016-09-04.
//

import Cocoa

/// Represents a pomf clone the user can upload to
class AKPomf {
    /// The name of this pomf clone
    var name : String = "";
    
    /// The URL to this pomf clone(E.g. https://mixtape.moe/)
    var url : String = "";
    
    /// Uploads the file at the given path to this pomf clone and returns the URL, status message and if the upload was successful
    func uploadFile(filePath : String) -> (String, String, Bool) {
        /// The URL to the uploaded file
        var url : String = "";
        
        /// The status message of the upload
        var statusMessage : String = "";
        
        /// Was the upload
        var successful : Bool = false;
        
        // Return everything
        return (url, statusMessage, successful);
    }
}