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
    var uploadStatusBarItem : NSStatusItem = NSStatusItem();

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        // Create the status bar item
        createStatusItem();
    }
    
    /// Creates uploadStatusBarItem
    func createStatusItem() {
        // Create uploadStatusBarItem
        uploadStatusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
        
        // Set the item's image scaling
        (uploadStatusBarItem.button!.cell as! NSButtonCell).imageScaling = .ScaleProportionallyDown;
        
        // Set the icon
        uploadStatusBarItem.image = NSImage(named: "AKUploadIcon")!;
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

