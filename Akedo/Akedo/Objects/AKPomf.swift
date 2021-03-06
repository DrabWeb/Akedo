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
class AKPomf: NSObject {
    
    // MARK: - Properties
    
    /// The name of this pomf clone
    var name : String = "";
    
    /// The URL to this pomf clone(E.g. https://mixtape.moe/)
    var url : String = "";
    
    /// The max file size for uploading(in MB)
    var maxFileSize : Int = 0;
    
    /// For some pomf hosts they use a subdomain for uploaded files(E.g. pomf.cat, uses a.pomf.cat for uploads), this variable is the "a." in that example, optional
    var uploadUrlPrefix : String = "";
    
    
    // MARK: - Functions
    
    /// Uploads the file(s) at the given path(s) to this pomf clone and calls the completion handler with the URL(s), and if the upload was successful
    /// Uploads the given files to this pomf host
    ///
    /// - Parameters:
    ///   - filePaths: The paths of the files to upload
    ///   - completionHandler: The completion handler for when the operation finishes, passed the URLs of the uploaded files and if it the upload was successful
    func upload(files : [String], completionHandler : @escaping ((([String], Bool)) -> ())) {
        /// The URLs to the uploaded files
        var urls : [String] = [];
        
        /// Was the upload successful?
        var successful : Bool = false;
        
        print("AKPomf: Uploading \"\(files)\" to \(self.name)(\(self.url + "upload.php"))");
        
        // Make the upload request
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // For every file to upload...
                for(_, currentFilePath) in files.enumerated() {
                    // Append the current file path to the `files[]` multipart data
                    multipartFormData.append(URL(fileURLWithPath: currentFilePath), withName: "files[]");
                }
            },
            to: self.url + "upload.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                    // If the encode was a success...
                    case .success(let upload, _, _):
                        upload.responseJSON { (responseData) -> Void in
                            /// The string of JSON that will be returned when the POST request finishes
                            let responseJsonString : NSString = NSString(data: responseData.data!, encoding: String.Encoding.utf8.rawValue)!;
                            
                            // If the the response data isnt nil...
                            if let dataFromResponseJsonString = responseJsonString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false) {
                                /// The JSON from the response string
                                let responseJson = JSON(data: dataFromResponseJsonString);
                                
                                // For every uploaded file...
                                for(_, currentFileData) in responseJson["files"] {
                                    /// The current file URL
                                    var currentUrl : String = currentFileData["url"].stringValue.replacingOccurrences(of: "\\", with: "");
                                    
                                    // If the URL doesnt have a ://...
                                    if(!currentUrl.contains("://")) {
                                        // Fix up the URL
                                        /// The prefix of this pomf clones URL(Either http:// or https://)
                                        let urlPrefix : String = (self.url.substring(to: self.url.range(of: "://")!.lowerBound)) + "://";
                                        
                                        // Set currentUrl to `urlPrefix + uploadUrlPrefix + self.url` without `prefix + currentUrl`
                                        currentUrl = urlPrefix + (self.uploadUrlPrefix + self.url.replacingOccurrences(of: urlPrefix, with: "")) + currentUrl;
                                    }
                                    
                                    // Add the current file's URL to `urls`
                                    urls.append(currentUrl);
                                }
                                
                                // Set `successful`
                                successful = responseJson["success"].boolValue;
                                
                                // Call the completion handler
                                completionHandler((urls, successful));
                            }
                    }
                    // If the encode was a failure...
                    case .failure(let encodingError):
                        print("AKPomf(\(self.name)): Error encoding \"\(files)\", \(encodingError)");
                    
                        // Post the notification saying the file failed to encode
                        /// The notification to say the file encoding failed
                        let fileEncodingFailedNotification : NSUserNotification = NSUserNotification();
                        
                        // Setup the notification
                        fileEncodingFailedNotification.title = "Akedo";
                        fileEncodingFailedNotification.informativeText = "Failed to encode \(files.count) file\((files.count == 1) ? "" : "s") for \(self.name)";
                        
                        // Deliver the notification
                        NSUserNotificationCenter.default.deliver(fileEncodingFailedNotification);
                }
            }
        )
    }
    
    // Init with a name, URL and max file size
    init(name: String, url : String, maxFileSize : Int) {
        self.name = name;
        self.url = url;
        self.maxFileSize = maxFileSize;
    }
    
    // Init with a name, URL, max file size and URL prefix
    init(name: String, url : String, maxFileSize : Int, uploadUrlPrefix : String) {
        self.name = name;
        self.url = url;
        self.maxFileSize = maxFileSize;
        self.uploadUrlPrefix = uploadUrlPrefix;
    }
}
