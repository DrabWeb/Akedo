//
//  AKPomfSelectionViewController.swift
//  Akedo
//
//  Created by Seth on 2016-09-08.
//

import Cocoa

class AKPomfSelectionViewController: NSViewController {
    
    /// The main window of this view controller
    var window : NSWindow = NSWindow();
    
    /// The visual effect view for the titlebar of the window
    @IBOutlet var titlebarVisualEffectView: NSVisualEffectView!
    
    /// The visual effect view for the background of the window
    @IBOutlet var backgroundVisualEffectView: NSVisualEffectView!
    
    /// The pomf clones to show in the pomf list table view
    var pomfListItems : [AKPomf] = [AKPomf(name: "mixtape.moe", url: "https://mixtape.moe/"), AKPomf(name: "pomf.cat", url: "https://pomf.cat/"), AKPomf(name: "catgirlsare.sexy", url: "https://catgirlsare.sexy/")];
    
    /// The scroll view for pomfListTableView
    @IBOutlet weak var pomfListTableViewScrollView: NSScrollView!
    
    /// The table view for letting the user pick a pomf clone to upload to
    @IBOutlet weak var pomfListTableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        pomfListTableView.reloadData();
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Center the window
        self.window.center();
        
        // Fix the X positioning
        self.window.setFrame(NSRect(x: (NSScreen.mainScreen()!.frame.width / 2) - (self.window.frame.width / 2), y: self.window.frame.origin.y, width: self.window.frame.width, height: self.window.frame.height), display: false);
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        window = NSApplication.sharedApplication().windows.last!;
        
        // Style the visual effect views
        titlebarVisualEffectView.material = .Titlebar;
        backgroundVisualEffectView.material = .Dark;
        
        // Style the window's titlebar
        window.titleVisibility = .Hidden;
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.titlebarAppearsTransparent = true;
        window.standardWindowButton(.CloseButton)?.superview?.superview?.removeFromSuperview();
        
        // Set the window's level
        window.level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey));
        
        // Disable moving the window
        self.window.movable = false;
    }
}

extension AKPomfSelectionViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        // Return the amount of items in tagListItems
        return self.pomfListItems.count;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view for the cell we want to modify
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: nil) as! NSTableCellView;
        
        // If this is the main column...
        if(tableColumn!.identifier == "Main Column") {
            /// cellView as a AKPomfTableCellView
            let pomfListTableCellView : AKPomfTableCellView = cellView as! AKPomfTableCellView;
            
            /// The data for this cell
            let cellData : AKPomf = pomfListItems[row];
            
            // Display the cell's data
            
            // Return the modified cell view
            return pomfListTableCellView as NSTableCellView;
        }
        
        // Return the unmodified cell view, we dont need to do anything
        return cellView;
    }
}

extension AKPomfSelectionViewController: NSTableViewDelegate {
    
}