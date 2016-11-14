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
    
    /// All the pomf hosts the user can use
    var pomfHosts : [AKPomf] = [AKPomf(name: "Mixtape.moe", url: "https://mixtape.moe/", maxFileSize: 100),
                                AKPomf(name: "Pomf.cat", url: "https://pomf.cat/", maxFileSize: 75, uploadUrlPrefix: "a."),
                                AKPomf(name: "Sugoi~", url: "https://sugoi.vidyagam.es/", maxFileSize: 100),
                                AKPomf(name: "Fuwa fuwa~", url: "https://p.fuwafuwa.moe/", maxFileSize: 256),
        AKPomf(name: "Kyaa", url: "https://kyaa.sg/", maxFileSize: 100, uploadUrlPrefix: "r.")];
//                                AKPomf(name: "Fluntcaps", url: "https://fluntcaps.me/", maxFileSize: 500, uploadUrlPrefix: "a.")];

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // Create the status bar item
        createStatusItem();
        
        // Set the user notification center delegate
        NSUserNotificationCenter.default.delegate = self;
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        // Always show notifications, even when the app is active
        return true;
    }
    
    /// Creates uploadStatusBarItem
    func createStatusItem() {
        // Create uploadStatusItem
        uploadStatusItem = NSStatusBar.system().statusItem(withLength: -1);
        
        // Set the item's image scaling
        (uploadStatusItem.button!.cell as! NSButtonCell).imageScaling = .scaleProportionallyDown;
        
        // Set the icon
        uploadStatusItem.image = NSImage(named: "AKUploadIcon")!;
        
        // Set the target and action
        uploadStatusItem.button!.target = self;
        uploadStatusItem.button!.action = #selector(AppDelegate.uploadStatusItemPressed);
    }
    
    /// Called when the user presses uploadStatusItem
    func uploadStatusItemPressed() {
        /// The open panel for prompting for file(s) to upload
        let openPanel : NSOpenPanel = NSOpenPanel();
        
        // Setup the open panel
        openPanel.canChooseDirectories = false;
        openPanel.prompt = "Upload";
        openPanel.allowsMultipleSelection = true;
        
        NSApplication.shared().activate(ignoringOtherApps: true);
        
        // Run the open panel, and if the user selects "Upload"...
        if(Bool(openPanel.runModal() as NSNumber)) {
            /// The list of files to upload
            var fileList : [String] = [];
            
            // For every file URL selected in the openPanel...
            for(_, currentFileUrl) in openPanel.urls.enumerated() {
                // Add the current file URL to fileList
                fileList.append(currentFileUrl.absoluteString.removingPercentEncoding!.replacingOccurrences(of: "file://", with: ""));
            }
            
            // Upload the files
            uploadFiles(fileList);
        }
        // If the user cancelled the open panel...
        else {
            // Re-activate the previous app
            NSApplication.shared().hide(self);
        }
    }
    
    /// The last files that were sent to be uploaded
    var lastUploadFiles : [String] = [];
    
    /// The last pomf host the user selected
    var lastUploadHost : AKPomf? = nil;
    
    // Prompts the user to select a pomf host and then uploads the given files to that host
    func uploadFiles(_ filePaths : [String]) {
        // Set lastUploadFiles
        lastUploadFiles = filePaths;
        
        /// The combined size of all the files in filePaths, in megabytes
        let combinedSize : Float = FileManager.default.sizeOfFiles(filePaths);
        
        print("AppDelegate: Trying to upload \(combinedSize)MB of files");
        
        // Print that we are prompting the user for a pomf host
        print("AppDelegate: Asking the user to select a pomf host");
        
        // Create the new pomf selection window
        let pomfSelectionWindowController : NSWindowController = NSStoryboard(name: "Main", bundle: Bundle.main).instantiateController(withIdentifier: "PomfSelectionWindowController") as! NSWindowController;
        
        // Load the window
        pomfSelectionWindowController.loadWindow();
        
        /// The AKPomfSelectionViewController of pomfSelectionWindowController
        let pomfSelectionViewController : AKPomfSelectionViewController = (pomfSelectionWindowController.contentViewController as! AKPomfSelectionViewController);
        
        // Set filesSize
        pomfSelectionViewController.filesSize = combinedSize;
        
        // Set the pomf host selected target and action
        pomfSelectionViewController.pomfSelectedTarget = self;
        pomfSelectionViewController.pomfSelectedAction = #selector(AppDelegate.pomfHostSelected(_:));
        
        if(pomfSelectionViewController.pomfListItems.count != 0) {
            // Present the pomf host selection window
            pomfSelectionWindowController.window!.makeKeyAndOrderFront(self);
        }
        else {
            pomfSelectionWindowController.window!.close();
        }
    }
    
    /// Called when the user selects a pomf host presented by uploadFiles
    func pomfHostSelected(_ pomf : AKPomf) {
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
        NSUserNotificationCenter.default.deliver(uploadingNotification);
        
        // Upload the files
        pomf.uploadFiles(lastUploadFiles, completionHandler: pomfUploadCompleted)
    }
    
    /// Called when the pomf upload from pomfHostSelected is completed
    func pomfUploadCompleted(_ response : ([String], Bool)) {
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
            NSUserNotificationCenter.default.deliver(uploadedNotification);
            
            // Print that we uploaded the files
            print("AppDelegate: Uploaded \(lastUploadFiles) to \(lastUploadHost)");
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
            NSUserNotificationCenter.default.deliver(uploadFailedNotification);
            
            // Print that we failed to upload the files
            print("AppDelegate: Failed to upload \(lastUploadFiles) to \(lastUploadHost!.name)");
        }
        
        // If the upload was succesful and at least one file uploaded...
        if(response.1 && response.0.count > 0) {
            // Copy the URLs to the clipboard
            /// The string for all the URLs of the uploaded files
            var urlsString : String = "";
            
            // For every URL in the responses uploaded files...
            for(_, currentUrl) in response.0.enumerated() {
                // Append the current URL to urlsString with a trailing new line
                urlsString.append(currentUrl + "\n");
            }
            
            // Remove the final trailing new line
            urlsString = urlsString.substring(to: urlsString.characters.index(before: urlsString.endIndex));
            
            // Copy urlsString to the pasteboard
            // Add the string type to the general pasteboard
            NSPasteboard.general().declareTypes([NSStringPboardType], owner: nil);
            
            // Set the string of the general pasteboard to urlsString
            NSPasteboard.general().setString(urlsString, forType: NSStringPboardType);
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
