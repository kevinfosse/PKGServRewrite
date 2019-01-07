//
//  ViewController.swift
//  PKGServ
//
//  Created by Dylan Bolger on 1/7/19.
//  Copyright © 2019 Dylan Bolger. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var contentsView: NSTableView!
    @IBOutlet weak var statusField: NSTextField!
    @IBOutlet weak var pathField: NSTextField!
    @IBOutlet weak var localAddressField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var hostedTextField: NSTextField!
    
    @IBAction func networkPrefsPressed(_ sender: NSButton) {
    }
    @IBAction func helpButtonPressed(_ sender: NSButton) {
    }
    @IBAction func makeListButtonPressed(_ sender: NSButton) {
    }
    @IBAction func folderButtonPressed(_ sender: NSButton) {
    }
    @IBAction func changePortButtonPressed(_ sender: NSButton) {
    }
    @IBAction func serverButtonPressed(_ sender: NSButton) {
    }
    @IBAction func refreshButtonPressed(_ sender: NSButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

