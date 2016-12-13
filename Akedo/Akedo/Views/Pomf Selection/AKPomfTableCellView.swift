//
//  AKPomfTableCellView.swift
//  Akedo
//
//  Created by Seth on 2016-09-08.
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
    var clickAction : Selector? = nil;
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    /// Displays the given AKPomf's data in this cell, and sets representedPomf to its
    func displayPomf(_ pomf : AKPomf) {
        // Set representedPomf
        representedPomf = pomf;
        
        // Display the data
        self.nameLabel.stringValue = representedPomf!.name + " (\(pomf.maxFileSize) MB)";
        self.urlLabel.stringValue = representedPomf!.url;
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent);
        
        // Call clickAction
        if(clickAction != nil) {
            _ = clickTarget?.perform(clickAction!, with: self.representedPomf!);
        }
    }
}
