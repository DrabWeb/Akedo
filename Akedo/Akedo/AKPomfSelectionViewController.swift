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
    var pomfListItems : [AKPomf] = (NSApplication.shared().delegate as! AppDelegate).pomfHosts;
    
    /// The scroll view for pomfListTableView
    @IBOutlet weak var pomfListTableViewScrollView: NSScrollView!
    
    /// The table view for letting the user pick a pomf clone to upload to
    @IBOutlet weak var pomfListTableView: NSTableView!
    
    /// The local key listener for picking up when the user presses a number key so they can quick select a pomf clone
    var keyListener : AnyObject? = nil;
    
    /// The object to perform pomfSelectedAction
    var pomfSelectedTarget : AnyObject? = nil;
    
    /// The selector to call when the user selects a pomf host, passed the selected AKPomf
    var pomfSelectedAction : Selector? = nil;
    
    /// The combined size of the files the user is trying to upload
    var filesSize : Float = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // Style the window
        styleWindow();
        
        // Reload the pomf list table view
        pomfListTableView.reloadData();
        
        // Create the key listener
        keyListener = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: keyPressed) as AnyObject?;
    }
    
    /// Called when the user presses a key
    func keyPressed(_ event : NSEvent) -> NSEvent {
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
        
        // Make sure to only show the pomf hosts that will let us upload our files
        
        /// The new items for pomfListItems, only includes the hosts that allow the size we are trying to upload
        var newPomfListItems : [AKPomf] = [];
        
        // For every current pomf list item...
        for(_, currentItem) in self.pomfListItems.enumerated() {
            // If the combined file size is less than the current pomf's file size limit...
            if(filesSize < Float(currentItem.maxFileSize)) {
                // Add the current pomf to newPomfListItems
                newPomfListItems.append(currentItem);
            }
        }
        
        // If newPomfListItems isnt empty...
        if(newPomfListItems.count != 0) {
            // Set pomfListItems to newPomfListItems
            self.pomfListItems = newPomfListItems;
            
            // Reload pomfListTableView
            pomfListTableView.reloadData();
        }
        // If newPomfListItems is empty...
        else {
            // Send a notification saying the files are too big and cancel the upload
            /// The notification to tell the user the files are too large
            let tooLargeNotification : NSUserNotification = NSUserNotification();
            
            // Setup the notification
            tooLargeNotification.title = "Akedo";
            tooLargeNotification.informativeText = "Selected file(s) are too large(\(filesSize)MB)";
            
            // Post the notification
            NSUserNotificationCenter.default.deliver(tooLargeNotification);
            
            // Close the window
            self.window.close();
            
            // Destroy the key listener
            NSEvent.removeMonitor(keyListener!);
            
            // Reactivate the previous app
            NSApplication.shared().hide(self);
            
            // Print that we couldnt upload the files because they were too large
            print("AKPomfSelectionViewController: Selected file(s) are too large(\(filesSize)MB)");
        }
        
        // Center the window
        self.window.center();
        
        // Fix the X positioning
        self.window.setFrame(NSRect(x: (NSScreen.main()!.frame.width / 2) - (self.window.frame.width / 2), y: self.window.frame.origin.y, width: self.window.frame.width, height: self.window.frame.height), display: false);
        
        // Bring this window to the front
        self.window.makeKeyAndOrderFront(self);
    }
    
    /// Called when the user clicks or uses a keycombo to select a pomf to upload to
    func pomfSelected(_ pomf : AKPomf) {
        // Print what pomf host the user selected
        print("AKPomfSelectionViewController: User selected \"\(pomf.name)\" as host");
        
        // Close the window
        self.window.close();
        
        // Destroy the key listener
        NSEvent.removeMonitor(keyListener!);
        
        // Reactivate the previous app
        NSApplication.shared().hide(self);
        
        // Call pomfSelectedAction
        if(pomfSelectedAction != nil) {
            pomfSelectedTarget?.perform(pomfSelectedAction!, with: pomf);
        }
    }
    
    /// Styles the window
    func styleWindow() {
        // Get the window
        window = NSApplication.shared().windows.last!;
        
        // Style the visual effect views
        titlebarVisualEffectView.material = .titlebar;
        backgroundVisualEffectView.material = .dark;
        
        // Style the window's titlebar
        window.titleVisibility = .hidden;
        window.styleMask.insert(NSFullSizeContentViewWindowMask);
        window.titlebarAppearsTransparent = true;
        window.standardWindowButton(.closeButton)?.superview?.superview?.removeFromSuperview();
        
        // Set the window's level
        window.level = Int(CGWindowLevelForKey(.floatingWindow));
        
        // Disable moving the window
        self.window.isMovable = false;
    }
}

extension AKPomfSelectionViewController: NSTableViewDataSource {
    func numberOfRows(in aTableView: NSTableView) -> Int {
        // Return the amount of items in tagListItems
        return self.pomfListItems.count;
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        /// The cell view for the cell we want to modify
        let cellView: NSTableCellView = tableView.make(withIdentifier: tableColumn!.identifier, owner: nil) as! NSTableCellView;
        
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
            pomfListTableCellView.clickAction = #selector(AKPomfSelectionViewController.pomfSelected(_:));
            
            // Return the modified cell view
            return pomfListTableCellView as NSTableCellView;
        }
        
        // Return the unmodified cell view, we dont need to do anything
        return cellView;
    }
}

extension AKPomfSelectionViewController: NSTableViewDelegate {
    
}
