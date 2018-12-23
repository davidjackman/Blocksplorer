//
//  BlockChainViewController.swift
//  Blocksplorer
//
//  Created by David Jackman on 12/22/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

import UIKit

class BlockChainViewController: UIViewController {
    
    static let loadBlocks = "Load Blocks"
    static let reloadBlocks = "Reload Chain"
    
    let blockChainController = BlockChainController.shared
    
    @IBOutlet weak var loadButton: UIButton!
    @IBAction func load(_ sender: UIButton) {
        if let title = sender.titleLabel?.text, BlockChainViewController.reloadBlocks == title {
            loadChain()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadChain()
    }
    
    fileprivate func loadChain() {
        blockChainController.loadChain { (success, error) in
            if success {
                self.updateDisplay(blockChain: self.blockChainController.blockChain!)
            } else if let e = error {
                self.updateDisplay(error: e)
            }
        }
    }
    
    fileprivate func displayLoadButton(reload: Bool = false) {
        let title = reload ? BlockChainViewController.reloadBlocks : BlockChainViewController.loadBlocks
        loadButton.setTitle(title, for: .normal)
        loadButton.isEnabled = true
    }

    fileprivate func updateDisplay(error: Error) {
        //TODO: Display Error in view
        self.displayLoadButton(reload: true)
    }
    
    fileprivate func updateDisplay(blockChain: BlockChain) {
        self.displayLoadButton()
    }
    
}

extension BlockChainViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let button = sender as? UIButton,
            button.titleLabel?.text == BlockChainViewController.loadBlocks,
            let vc = segue.destination as? BlocksTableViewController {
            
            vc.blockChainController = self.blockChainController
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard let button = sender as? UIButton else {
            return false
        }
        return button.titleLabel?.text == BlockChainViewController.loadBlocks
    }

}
