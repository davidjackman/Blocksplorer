//
//  BlockDetailViewController.swift
//  Blocksplorer
//
//  Created by David Jackman on 12/22/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

import UIKit

class BlockDetailViewController: UIViewController {
    
    var block: Block? {
        didSet {
            updateDisplay()
        }
    }

    @IBOutlet weak var textView: UITextView!
    
    @IBAction func toggleDisplay(_ sender: UIBarButtonItem) {
        if sender.title == "Raw" {
            sender.title = "Details"
            updateDisplay(raw: true)
            print("Display Raw")
        } else {
            sender.title = "Raw"
            updateDisplay()
            print("Display Details")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.rightBarButtonItem = self.toolbarItems!.first!
        
        updateDisplay()
    }
    
    fileprivate func updateDisplay(raw: Bool = false) {
//        guard let textView = textView else { return }
        
        if raw {
            textView?.attributedText = rawText
        } else {
            textView?.attributedText = detailText
        }
    }
    
    var rawText: NSAttributedString? {
        guard let block = block, let json = block.json else { return nil }
        return NSAttributedString(string: "\(json)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)])
    }
    
    var detailText: NSAttributedString? {
        guard let block = block else { return nil }
        
        let bold = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        let normal = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
        let result = NSMutableAttributedString(string: "Producer: ", attributes: bold)
        result.append(NSAttributedString(string: block.producer, attributes: normal))
        result.append(NSAttributedString(string: "\nTransactionCount: ", attributes: bold))
        result.append(NSAttributedString(string: "\(block.transactionCount)", attributes: normal))
        result.append(NSAttributedString(string: "\nSignature: \n", attributes: bold))
        result.append(NSAttributedString(string: block.signature, attributes: normal))

        return result
    }
    
}


