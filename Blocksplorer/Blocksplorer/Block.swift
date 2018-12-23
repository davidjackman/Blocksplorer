//
//  Block.swift
//  Blocksplorer
//
//  Created by David Jackman on 12/21/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

import Foundation

/*
 2018-12-21 16:12:11.561727-0800 Blocksplorer[76392:782464] https://api.eosnewyork.io/v1/chain/get_info
 {
     "block_cpu_limit" = 181101;
     "block_net_limit" = 1047360;
     "chain_id" = aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906;
     "head_block_id" = 01fcb81860fc267ca437e3e29dfb5006c0341b223ed90e39c767f69a7cc3b750;
     "head_block_num" = 33339416;
     "head_block_producer" = eosswedenorg;
     "head_block_time" = "2018-12-22T00:12:13.500";
     "last_irreversible_block_id" = 01fcb6d1e0eed3e75c7892eb1785cf00cb876eb3bfbe4f83a4df692436dc7397;
     "last_irreversible_block_num" = 33339089;
     "server_version" = 60c8bace;
     "server_version_string" = "v1.4.2";
     "virtual_block_cpu_limit" = 71203605;
     "virtual_block_net_limit" = 1048576000;
 }

 */

struct BlockChain : Codable {

    let id: String
    let headBlockNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "chain_id"
        case headBlockNumber = "head_block_num"
    }
}

struct Block : Codable {
    
    let id: String
    let number: Int
    let producer: String
    let signature: String
    var transactionCount: Int {
        return (json?["transactions"] as? Array ?? []).count
    }
    
    var json: [String : Any]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case number = "block_num"
        case producer
        case signature = "producer_signature"
    }
    
}

