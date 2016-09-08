//
//  AKPomf.swift
//  Akedo
//
//  Created by Seth on 2016-09-04.
//

import Cocoa
import Alamofire
import SwiftyJSON

/// Represents a pomf clone the user can upload to
class AKPomf {
    /// The name of this pomf clone
    var name : String = "";
    
    /// The URL to this pomf clone(E.g. https://mixtape.moe/)
    var url : String = "";
    
    /// Uploads the file(s) at the given path(s) to this pomf clone and calls the completion handler with the URL(s), and if the upload was successful
    func uploadFile(filePaths : [String], completionHandler : ((([String], Bool)) -> ())) {
        /// The URL to the uploaded file(s)
        var urls : [String] = [];
        
        /// Was the upload successful
        var successful : Bool = false;
        
        // Print what file we are uploading and where to
        print("Uploading \"\(filePaths)\" to \(self.name)(\(self.url + "upload.php"))");
        
        // Make the upload request
        Alamofire.upload(.POST, self.url + "upload.php",
            multipartFormData: { multipartFormData in
                // For every file to upload...
                for(_, currentFilePath) in filePaths.enumerate() {
                    // Append the current file path to the files[] multipart data
                    multipartFormData.appendBodyPart(fileURL: NSURL(fileURLWithPath: currentFilePath), name: "files[]");
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    // If the encode was a success...
                    case .Success(let upload, _, _):
                        upload.responseJSON { (responseData) -> Void in
                            /// The string of JSON that will be returned when the POST request finishes
                            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: NSUTF8StringEncoding)!;
                            
                            // If the the response data isnt nil...
                            if let dataFromResponseJsonString = responseJsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                                /// The JSON from the response string
                                let responseJson = JSON(data: dataFromResponseJsonString);
                                
                                // For every uploaded file...
                                for(_, currentFileData) in responseJson["files"] {
                                    // Add the current file's URL to urls
                                    urls.append(currentFileData["url"].stringValue.stringByReplacingOccurrencesOfString("\\", withString: ""));
                                }
                                
                                // Set successful
                                successful = responseJson["success"].boolValue;
                                
                                // Call the completion handler
                                completionHandler((urls, successful));
                            }
                    }
                    // If the encode was a failure...
                    case .Failure(let encodingError):
                        // Print the encoding error
                        print("AKPomf(\(self.name)): Error encoding \"\(filePaths)\", \(encodingError)");
                }
            }
        )
    }
    
    // Init with a name and URL
    init(name: String, url : String) {
        self.name = name;
        self.url = url;
    }
}