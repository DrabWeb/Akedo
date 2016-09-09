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
    var pomfListItems : [AKPomf] = [AKPomf(name: "Mixtape.moe", url: "https://mixtape.moe/"), AKPomf(name: "Pomf.cat", url: "https://pomf.cat/"), AKPomf(name: "Catgirlsare.sexy", url: "https://catgirlsare.sexy/")];
    
    /// The scroll view for pomfListTableView
    @IBOutlet weak var pomfListTableViewScrollView: NSScrollView!
    
    /// The table view for letting the user pick a pomf clone to upload to
    @IBOutlet weak var pomfListTableView: NSTableView!
    
    /// The local key listener for picking up when the user presses a number key so they can quick select a pomf clone
    var keyListener : AnyObject? = nil;
    
    /// The object to perform pomfSelectedAction
    var pomfSelectedTarget : AnyObject? = nil;
    
    /// The selector to call when the user selects a pomf host, passed the selected AKPomf
    var pomfSelectedAction : Selector = Selector("");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Reload the pomf list table view
        pomfListTableView.reloadData();
        
        // Create the key listener
        keyListener = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: keyPressed);
    }
    
    /// Called when the user presses a key
    func keyPressed(event : NSEvent) -> NSEvent {
        /// The number that the user may have pressed(-1 if the user didnt press a number)
        var pressedNumber : Int = -1;
            
        // Switch on the key code and set pressedNumber accordingly
        switch event.keyCode {
            case 18,83:
                pressedNumber = 1;
                break;
            case 19,84:
                pressedNumber = 2;
                break;
            case 20,85:
                pressedNumber = 3;
                break;
            case 21,86:
                pressedNumber = 4;
                break;
            case 23,87:
                pressedNumber = 5;
                break;
            case 22,88:
                pressedNumber = 6;
                break;
            case 26,89:
                pressedNumber = 7;
                break;
            case 28,91:
                pressedNumber = 8;
                break;
            case 25,92:
                pressedNumber = 9;
                break;
            default:
                break;
        }
            
        // If the pressed number is greater than -1...
        if(pressedNumber > -1) {
            // If pressedNumber is in range of pomfListItems...
            if(pressedNumber <= pomfListItems.count) {
                // Call pomfSelected with the pomf clone at the pressed number
                pomfSelected(pomfListItems[pressedNumber - 1]);
            }
        }
        
        return event;
    }
    
    override func viewWillAppear() {
        super.viewWillAppear();
        
        // Center the window
        self.window.center();
        
        // Fix the X positioning
        self.window.setFrame(NSRect(x: (NSScreen.mainScreen()!.frame.width / 2) - (self.window.frame.width / 2), y: self.window.frame.origin.y, width: self.window.frame.width, height: self.window.frame.height), display: false);
        
        // Bring this window to the front
        self.window.makeKeyAndOrderFront(self);
    }
    
    /// Called when the user clicks or uses a keycombo to select a pomf to upload to
    func pomfSelected(pomf : AKPomf) {
        // Print what pomf host the user selected
        print("AKPomfSelectionViewController: User selected \"\(pomf.name)\" as host");
        
        // Close the window
        self.window.close();
        
        // Destroy the key listener
        NSEvent.removeMonitor(keyListener!);
        
        // Reactivate the previous app
        NSApplication.sharedApplication().hide(self);
        
        // Call pomfSelectedAction
        pomfSelectedTarget?.performSelector(pomfSelectedAction, withObject: pomf);
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
            pomfListTableCellView.displayPomf(cellData);
            
            // Set the cell's click target and action
            pomfListTableCellView.clickTarget = self;
            pomfListTableCellView.clickAction = Selector("pomfSelected:");
            
            // Return the modified cell view
            return pomfListTableCellView as NSTableCellView;
        }
        
        // Return the unmodified cell view, we dont need to do anything
        return cellView;
    }
}

extension AKPomfSelectionViewController: NSTableViewDelegate {
    
}