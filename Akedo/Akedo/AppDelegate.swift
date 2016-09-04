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
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}