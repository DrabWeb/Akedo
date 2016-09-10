//
//  ShareViewController.swift
//  Upload with Akedo
//
//  Created by Seth on 2016-09-10.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController {

    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()
    
        // Insert code here to customize the view
    }

    @IBAction func send(sender: AnyObject?) {
        /// The paths to all the files that were shared
        var filePaths : [String] = [];
        
        // if the first input is an NSExtensionItem...
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            // For every attachment as an NSItemProvider...
            for(currentIndex, currentItem) in (item.attachments! as! [NSItemProvider]).enumerate() {
                // If the current item conforms the the file URL type indentifier...
                if currentItem.hasItemConformingToTypeIdentifier("public.url") {
                    // Load the file URL of this attachment
                    currentItem.loadItemForTypeIdentifier("public.url", options: nil, completionHandler: { (url, error) -> Void in
                        // If shareURL is an NSURL...
                        if let shareURL = url as? NSURL {
                            // Add the current URL to filePaths
                            filePaths.append(shareURL.absoluteString.stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("file://", withString: ""));
                            
                            // If this is the last item...
                            if((currentIndex + 1) == item.attachments!.count) {
                                /// The NSExtensionItems for filePaths, used for completeRequestReturningItems
                                var fileExtensionItems : [NSExtensionItem] = [];
                                
                                // For every item in filePaths...
                                for(_, currentPath) in filePaths.enumerate() {
                                    /// The extension item for currentItem
                                    let extensionItem : NSExtensionItem = NSExtensionItem();
                                    
                                    // Set the attachments of the item to currentPath
                                    extensionItem.attachments = [currentPath];
                                    
                                    // Add the new extension item to fileExtensionItems
                                    fileExtensionItems.append(extensionItem);
                                }
                                
                                // Tell Akedo to prompt for a pomf host and upload the files
                                self.extensionContext!.completeRequestReturningItems(fileExtensionItems, completionHandler: nil);
                            }
                        }
                    });
                }
            }
        }
    }

    @IBAction func cancel(sender: AnyObject?) {
        /// The error to return to the extension context for the reason to cancel the share
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil);
        
        // Tell the extension context to cancel with cancelError as the reason
        self.extensionContext!.cancelRequestWithError(cancelError);
    }
}
