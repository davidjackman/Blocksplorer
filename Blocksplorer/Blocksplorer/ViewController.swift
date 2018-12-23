//
//  ViewController.swift
//  Blocksplorer
//
//  Created by David Jackman on 12/21/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var blockServices : BlockServices!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://api.eosnewyork.io/v1/chain")!
        
        blockServices = BlockServices(baseURL: url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        go()
    }

    func go() {
        blockServices.getInfo { [weak self] (result) in
            switch result {
            case .success(let blockChain):
                self?.blockServices.getBlock(number: blockChain.headBlockNumber
                    , completion: { (blockResult) in
                        switch blockResult {
                        case .success(let block):
                            print(block)
                        default:
                            print("Block Lame")
                        }
                })
            default:
                print("Lame")
            }
        }
    }
    
}

