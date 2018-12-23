//
//  BlockChainController.swift
//  Blocksplorer
//
//  Created by David Jackman on 12/22/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

enum BlockChainError : Error {
    case initialization
    case blockLoad
    case abiLoad
}

import Foundation

class BlockChainController {
    
    static let shared: BlockChainController = BlockChainController()
    
    var blockChain: BlockChain?
    var blockServices = BlockServices(baseURL: URL(string: "https://api.eosnewyork.io/v1")!)
    
    var blocks = [Block]()
    
    init() {}
    
    func loadChain(completion: @escaping (Bool, Error?) -> ()) {
        blockChain = nil
        blocks.removeAll()
        DispatchQueue.main.async {
            self.blockServices.getInfo(completion: { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let blockChain):
                        guard let self = self else { completion(false, nil); return }
                        
                        self.blockChain = blockChain
                        completion(true, nil)
                        
                    case .failure(let error):
                        completion(false, error)
                    }
                }
            })
        }
    }

    func getBlocks(count: Int, completion: @escaping (Bool, Error?) -> ()) {
        guard let blockChain = blockChain else { completion(false, BlockChainError.initialization); return }
        
        blocks.removeAll(keepingCapacity: true)
        
        getBlocks(count: count, index: blockChain.headBlockNumber, completion: completion)
    }
    
    fileprivate func getBlocks(count: Int, index: Int, completion: @escaping (Bool, Error?) -> ()) {
        guard let blockChain = blockChain,
            index >= 0,
            index <= blockChain.headBlockNumber,
            count >= 0
            
            else {
                completion(false, BlockChainError.initialization)
                return
        }
        
        if blockChain.headBlockNumber == index {
            print("Getting HeadBlock")
        }
        
        blockServices.getBlock(number: index) { (result) in
            guard case .success(let block) = result else {
                DispatchQueue.main.async { completion(false, BlockChainError.blockLoad) }
                return
            }
            
            self.blocks.append(block)
            
            if count == 1 {
                DispatchQueue.main.async { completion(true, nil) }
            } else {
                print("Blocks so far \(self.blocks.count) index \(index) toGo \(count - 1)")
                self.getBlocks(count: count - 1, index: index - 1, completion: completion)
            }
        }
    }
    
    func block(at index: Int) -> Block? {
        guard index >= 0, index < blocks.count else { return nil }
        
        return blocks[index]
    }
    
//    func abi(forName name: String, completion: @escaping (ABISearchResult?, Error?) -> ()) {
//        blockServices.getABI(account: name) { (result) in
//            guard case .success(let abi) = result else {
//                DispatchQueue.main.async { completion(nil, BlockChainError.abiLoad) }
//                return
//            }
//            DispatchQueue.main.async { completion(abi, nil) }
//        }
//    }
}
