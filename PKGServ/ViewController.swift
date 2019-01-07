//
//  ViewController.swift
//  PKGServ
//
//  Created by Dylan Bolger on 1/7/19.
//  Copyright © 2019 Dylan Bolger. All rights reserved.
//

import Cocoa
import Swifter

class ViewController: NSViewController {

    @IBOutlet weak var contentsView: NSTableView!
    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var localAddressField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var hostedTextField: NSTextField!
    @IBOutlet weak var settingsStatusField: NSTextField!
    
    var selectedPath:String = ""
    let fm = FileManager.default
    let path = Bundle.main.resourcePath!
    let server = HttpServer()
    var localAddress : String = ""
    var serverPort : String = "80"
    var serverStarted = false
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            //if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {  // **ipv6 committed
            if addrFamily == UInt8(AF_INET){
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    func presentFolderSelection() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.title = "Select folder containing PKG file"
        
        panel.beginSheetModal(for:self.view.window!) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.selectedPath = panel.url!.path
                // do whatever you what with the file path
                self.pathField.stringValue = self.selectedPath
                print("User has selected : \(self.selectedPath)")
            }
            panel.close()
        }
    }
    
    @IBAction func networkPrefsPressed(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Network.prefPane"))
    }
    @IBAction func helpButtonPressed(_ sender: NSButton) {
        let helpAlert = NSAlert()
        helpAlert.alertStyle = .informational
        helpAlert.messageText = "How to obtain my local IP?"
        helpAlert.informativeText = "To obtain your Local IP address, you must go to the system > network preferences and it will be displayed under 'Status'."
        helpAlert.runModal()
    }
    @IBAction func makeListButtonPressed(_ sender: NSButton) {
        //make list file
    }
    @IBAction func folderButtonPressed(_ sender: NSButton) {
        if serverStarted == true {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Server running"
            alert.informativeText = "You cannot change the folder when the server is started"
            alert.runModal()
        } else {
            presentFolderSelection()
        }
    }
    @IBAction func changePortButtonPressed(_ sender: NSButton) {
        if serverStarted == true {
            settingsStatusField.stringValue = "Cannot change server port when server is running."
        } else {
            if portField.stringValue == "" {
                settingsStatusField.stringValue = "Please provide a valid port."
            } else {
                serverPort = portField.stringValue
                settingsStatusField.stringValue = "Server port changed to \(serverPort)."
            }
        }
        
    }
    @IBAction func serverButtonPressed(_ sender: NSButton) {
        let portInt = UInt16(serverPort)
        if(selectedPath == "") { // if the user hasn't defined a path, make them do so.
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "No selected folder"
            alert.informativeText = "Before starting the server, you must choose the folder containing the PKG."
            alert.runModal()
            presentFolderSelection()
        } else if serverStarted == false && selectedPath != "" { // if the server isn't started and the path has been defined, go ahead and start the server.
            serverStarted = !serverStarted
            server["/PKG/:path"] = shareFilesFromDirectory(selectedPath)
            server["/"] = scopes {
                html {
                    body {
                        center {
                            img { src = "http://www.psx-place.com/styles/nerva/xenforo/logo.png" }
                            h1 {
                                inner="Welcome to the PS3 PKGServer"
                            }
                            p {inner="Made by @kevxxf with help of @FivePixel"}
                            
                        }
                    }
                }
            }
            server["/files/:path"] = directoryBrowser("/")
            do {
                try server.start(portInt!, forceIPv4: true)
                print("Server is live on port \(try server.port()).")
                
            } catch {
                print("Server start error: \(error)")
            }
            sender.title = "Stop Server"
            statusField.textColor = NSColor.green
            statusField.stringValue = "Server running on port \(serverPort)"
        } else if serverStarted { // if the server is already running when the button is pressed, stop the server.
            serverStarted = !serverStarted
            server.stop()
            print("Server succesfully stopped.")
            sender.title = "Start Server"
            statusField.textColor = NSColor.red
            statusField.stringValue = "Server stopped"
        }
    }
    @IBAction func refreshButtonPressed(_ sender: NSButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        localAddressField.stringValue = getWiFiAddress()!
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

