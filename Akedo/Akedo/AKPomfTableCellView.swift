//
//  AKPomfTableCellView.swift
//  Akedo
//
//  Created by Seth on 2016-09-08.
//  Copyright © 2016 DrabWeb. All rights reserved.
//

import Cocoa

class AKPomfTableCellView: NSTableCellView {

    /// The label for displaying the name of this pomf clone
    @IBOutlet var nameLabel: NSTextField!
    
    /// The label for displaying the URL of this pomf clone
    @IBOutlet var urlLabel: NSTextField!
    
    /// The AKPomf this cell represents
    var representedPomf : AKPomf? = nil;
    
    /// The object to perform clickAction
    var clickTarget : AnyObject? = nil;
    
    /// The selector to perform when the user clicks this cell, passed representedPomf
    var clickAction : Selector = Selector("");
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    /// Displays the given AKPomf's data in this cell, and sets representedPomf to its
    func displayPomf(pomf : AKPomf) {
        // Set representedPomf
        representedPomf = pomf;
        
        // Display the data
        self.nameLabel.stringValue = representedPomf!.name;
        self.urlLabel.stringValue = representedPomf!.url;
    }
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent);
        
        // Call clickAction
        clickTarget?.performSelector(clickAction, withObject: self.representedPomf!);
    }
}
