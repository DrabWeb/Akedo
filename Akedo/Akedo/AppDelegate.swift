//
//  AppDelegate.swift
//  Akedo
//
//  Created by Seth on 2016-09-04.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// The main status item for Akedo
    var uploadStatusItem : NSStatusItem = NSStatusItem();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // Create the status bar item
        createStatusItem();
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
        
        // Run the open panel, and if the user selects "Upload"...
        if(Bool(openPanel.runModal())) {
            /// The list of files to upload
            var fileList : [String] = [];
            
            // For every file URL selected in the openPanel...
            for(_, currentFileUrl) in openPanel.URLs.enumerate() {
                // Add the current file URL to fileList
                fileList.append(currentFileUrl.absoluteString.stringByRemovingPercentEncoding!.stringByReplacingOccurrencesOfString("file://", withString: ""));
            }
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}