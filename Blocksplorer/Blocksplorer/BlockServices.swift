//
//  BlockServices.swift
//  Blocksplorer
//
//  Created by David Jackman on 12/21/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

import Foundation
import os.log

enum APIResult<T, E> where E: Error {
    case success(T)
    case failure(E)
}

enum BlockServicesError : Error {
    case parse
    case emptyData
}

protocol DataTaskCompatible {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    
}

extension URLSession : DataTaskCompatible {}

class BlockServices {
        
    var baseURL: URL
    var session: DataTaskCompatible
    
    init(baseURL url: URL, session: DataTaskCompatible = URLSession.shared) {
        self.baseURL = url
        self.session = session
    }
    
}

//MARK: Get Info
extension BlockServices {
    
    var getInfoURL: URL {
        let result = URL(string: "\(baseURL.absoluteString)/chain/get_info")!
        print(result.debugDescription)
        return result
    }
    
    var getInfoRequest: URLRequest {
        var request = URLRequest(url: getInfoURL)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }
    
    typealias GetInfoResult = APIResult<BlockChain, BlockServicesError>
    
    func getInfo(completion: @escaping (GetInfoResult) -> ()) {
        let task = session.dataTask(with: getInfoRequest) { (data, response, error) in
            
            if let d = data {
                do {
                    let blockChain: BlockChain = try JSONDecoder().decode(BlockChain.self, from: d)
                    completion(.success(blockChain))
                }
                catch {
                    completion(.failure(BlockServicesError.parse))
                }
            } else {
                completion(.failure(BlockServicesError.emptyData))
            }
        }
        task.resume()
    }
    
}

//MARK: Get Block
extension BlockServices {

    var getBlockURL: URL {
        return URL(string: "\(baseURL.absoluteString)/chain/get_block")!
    }
    
    func getBlockRequest(number: Int) -> URLRequest {
        var request = URLRequest(url: getBlockURL)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        request.httpBody = "{\"block_num_or_id\":\(number)}".data(using: .utf8)
        
        return request

    }
    
    typealias GetBlockResult = APIResult<Block, BlockServicesError>
    
    func getBlock(number: Int, completion: @escaping (GetBlockResult) -> ()) {
        let task = session
            .dataTask(with: getBlockRequest(number: number)) { (data, response, error) in
            if  let d = data,
                var block: Block = try? JSONDecoder().decode(Block.self, from: d) {
                
                block.json = try! JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String : Any]
                
                completion(.success(block))
            }
        }
        task.resume()
    }
    
}

