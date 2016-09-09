//
//  AppDelegate.swift
//  Akedo
//
//  Created by Seth on 2016-09-04.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    /// The main status item for Akedo
    var uploadStatusItem : NSStatusItem = NSStatusItem();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // Create the status bar item
        createStatusItem();
        
        // Set the user notification center delegate
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self;
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        // Always show notifications, even when the app is active
        return true;
    }
    
    /// Creates uploadStatusBarItem
    func createStatusItem() {
        // Create uploadStatusItem
        uploadStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        
        // Set the item's image scaling
        (uploadStatusItem.button!.cell as! NSButtonCell).imageScaling = .ScaleProportionallyDown;
        
        // Set the icon
        uploadStatusItem.image = NSImage(named: "AKUploadIcon")!;
        
        // Set the target and action
        uploadStatusItem.button!.target = self;
        uploadStatusItem.button!.action = Selector("uploadStatusItemPressed");
    }
    
    /// Called when the user presses uploadStatusItem
    func uploadStatusItemPressed() {
        /// The open panel for prompting for file(s) to upload
        let openPanel : NSOpenPanel = NSOpenPanel();
        
        // Setup the open panel
        openPanel.canChooseDirectories = false;
        openPanel.prompt = "Upload";
        openPanel.allowsMultipleSelection = true;
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true);
        
        // Run the open panel, and if the user selects "Upload"...
        if(Bool(openPanel.runModal())) {
            /// The list of files to upload
            var fileList : [String] = [];
            
            // For every file URL selected in the openPanel...
            for(_, currentFileUrl) in openPanel.URLs.enumerate() {
                // Add the current file URL to fileList
                fileList.append(currentFileUrl.absoluteString.stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("file://", withString: ""));
            }
            
            // Upload the files
            uploadFiles(fileList);
        }
        // If the user cancelled the open panel...
        else {
            // Re-activate the previous app
            NSApplication.sharedApplication().hide(self);
        }
    }
    
    /// The last files that were sent to be uploaded
    var lastUploadFiles : [String] = [];
    
    /// The last pomf host the user selected
    var lastUploadHost : AKPomf? = nil;
    
    // Prompts the user to select a pomf host and then uploads the given files to that host
    func uploadFiles(filePaths : [String]) {
        // Set lastUploadFiles
        lastUploadFiles = filePaths;
        
        // Print that we are prompting the user for a pomf host
        print("AppDelegate: Asking the user to select a pomf host");
        
        // Create the new pomf selection window
        let pomfSelectionWindowController : NSWindowController = NSStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateControllerWithIdentifier("PomfSelectionWindowController") as! NSWindowController;
        
        // Load the window
        pomfSelectionWindowController.loadWindow();
        
        /// The AKPomfSelectionViewController of pomfSelectionWindowController
        let pomfSelectionViewController : AKPomfSelectionViewController = (pomfSelectionWindowController.contentViewController as! AKPomfSelectionViewController);
        
        // Set the pomf host selected target and action
        pomfSelectionViewController.pomfSelectedTarget = self;
        pomfSelectionViewController.pomfSelectedAction = Selector("pomfHostSelected:");
        
        // Present the pomf host selection window
        pomfSelectionWindowController.window!.makeKeyAndOrderFront(self);
    }
    
    /// Called when the user selects a pomf host presented by uploadFiles
    func pomfHostSelected(pomf : AKPomf) {
        // Print the pomf host we will upload to
        print("AppDelegate: Uploading \(lastUploadFiles) to \"\(pomf.name)\"");
        
        // Set lastUploadHost
        lastUploadHost = pomf;
        
        // Post the notification saying we are uploading files and how many
        /// The notification to say how many files we are uploading and to where
        let uploadingNotification : NSUserNotification = NSUserNotification();
        
        // Setup the notification
        uploadingNotification.title = "Akedo";
        
        if(lastUploadFiles.count > 1) {
            uploadingNotification.informativeText = "Uploading \(lastUploadFiles.count) files to \(pomf.name)";
        }
        else {
            uploadingNotification.informativeText = "Uploading \(lastUploadFiles.count) file to \(pomf.name)";
        }
        
        // Deliver the notification
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(uploadingNotification);
        
        // Upload the files
        pomf.uploadFiles(lastUploadFiles, completionHandler: pomfUploadCompleted)
    }
    
    /// Called when the pomf upload from pomfHostSelected is completed
    func pomfUploadCompleted(response : ([String], Bool)) {
        // If the upload was succesful...
        if(response.1) {
            // Post the notification saying the upload completed
            /// The notification to say the upload completed
            let uploadedNotification : NSUserNotification = NSUserNotification();
            
            // Setup the notification
            uploadedNotification.title = "Akedo";
            
            if(response.0.count > 1) {
                uploadedNotification.informativeText = "Uploaded \(response.0.count) files to \(lastUploadHost!.name)";
            }
            else {
                uploadedNotification.informativeText = "Uploaded \(response.0.count) file to \(lastUploadHost!.name)";
            }
            
            // Deliver the notification
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(uploadedNotification);
        }
        // If the upload was unsuccesful...
        else {
            // Post the notification saying the upload failed
            /// The notification to say the upload completed
            let uploadFailedNotification : NSUserNotification = NSUserNotification();
            
            // Setup the notification
            uploadFailedNotification.title = "Akedo";
            
            if(response.0.count > 1) {
                uploadFailedNotification.informativeText = "Failed to upload \(response.0.count) files to \(lastUploadHost!.name)";
            }
            else if(response.0.count == 1) {
                uploadFailedNotification.informativeText = "Failed to upload \(response.0.count) file to \(lastUploadHost!.name)";
            }
            else {
                uploadFailedNotification.informativeText = "Failed to connect to \(lastUploadHost!.name)";
            }
            
            // Deliver the notification
            NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(uploadFailedNotification);
        }
        
        // If the upload was succesful and at least one file uploaded...
        if(response.1 && response.0.count > 0) {
            // Copy the URLs to the clipboard
            /// The string for all the URLs of the uploaded files
            var urlsString : String = "";
            
            // For every URL in the responses uploaded files...
            for(_, currentUrl) in response.0.enumerate() {
                // Append the current URL to urlsString with a trailing new line
                urlsString.appendContentsOf(currentUrl + "\n");
            }
            
            // Remove the final trailing new line
            urlsString = urlsString.substringToIndex(urlsString.endIndex.predecessor());
            
            // Copy urlsString to the pasteboard
            // Add the string type to the general pasteboard
            NSPasteboard.generalPasteboard().declareTypes([NSStringPboardType], owner: nil);
            
            // Set the string of the general pasteboard to urlsString
            NSPasteboard.generalPasteboard().setString(urlsString, forType: NSStringPboardType);
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}