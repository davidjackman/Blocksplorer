//
//  BlocksplorerTests.swift
//  BlocksplorerTests
//
//  Created by David Jackman on 12/21/18.
//  Copyright © 2018 David Jackman. All rights reserved.
//

import XCTest
@testable import Blocksplorer

class BlocksplorerTests: XCTestCase {
    
    var baseURL: URL {
        return URL(string: "https://api.eosnewyork.io/v1")!
    }
    
    var getBlockServices: BlockServices {
        let session = MockURLSession()
        session.data = Data.data(fromFileNamed: "GetBlock", type: "json", inBundle: Bundle(for: type(of: self)))
        let blockServices = BlockServices(baseURL: baseURL, session: session)
        return blockServices
    }
    
    func testGetBlock() {
        let expectation = XCTestExpectation(description: "Get Block Details")

        getBlockServices.getBlock(number: 1) { (result) in
            switch result {
                
            case .success(let block):
                XCTAssertEqual(block.id, "01fd0937264d28f8800404dda81ec8bcaf6f1fdad9394ebf0f0658cefc4ec1e2")
                XCTAssertEqual(block.number, 33360183)
                
            default:
                XCTFail("You didn't get a block back?")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    var infoBlockServices: BlockServices {
        let session = MockURLSession()
        session.data = Data.data(fromFileNamed: "GetInfo", type: "json", inBundle: Bundle(for: type(of: self)))
        
        let blockServices = BlockServices(baseURL: baseURL, session: session)
        return blockServices
    }
    
    func testGetBlockChainInfo() {
        let expectation = XCTestExpectation(description: "Get Block Chain Info")
        
        infoBlockServices.getInfo { (result) in
            
            switch result {
                
            case .success(let blockChain):
                XCTAssertEqual(blockChain.id, "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906")
                XCTAssertEqual(blockChain.headBlockNumber, 33360183)
                
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testControllerLoadsInfo() {
        let expectation   = XCTestExpectation(description: "Controller Get Blocks")
        
        let controller    = BlockChainController()
        let session       = MockURLSession()
        session.data = Data.data(fromFileNamed: "GetInfo", type: "json", inBundle: Bundle(for: type(of: self)))
        
        let blockServices = BlockServices(baseURL: baseURL, session: session)
        controller.blockServices = blockServices
        
        controller.loadChain { (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            XCTAssertNotNil(controller.blockChain)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testControllerLoadsBlocks() {
        let expectation   = XCTestExpectation(description: "Get Blocks")
        
        let controller    = BlockChainController()
        let session       = MockURLSession()
        session.data = Data.data(fromFileNamed: "GetBlock", type: "json", inBundle: Bundle(for: type(of: self)))
        
        let blockServices = BlockServices(baseURL: baseURL, session: session)
        controller.blockServices = blockServices
        controller.blockChain    = BlockChain(id: "1", headBlockNumber: 19)
        
        controller.getBlocks(count: 20) { (success, error) in
            XCTAssertNil(error)
            XCTAssertTrue(success)
            XCTAssertEqual(controller.blocks.count, 20)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testControllerFailsToLoadBlocks() {
        let expectation   = XCTestExpectation(description: "Get Blocks")
        
        let controller    = BlockChainController()
        let session       = MockURLSession()
        session.data = Data.data(fromFileNamed: "GetBlock", type: "json", inBundle: Bundle(for: type(of: self)))
        
        let blockServices = BlockServices(baseURL: baseURL, session: session)
        controller.blockServices = blockServices
        controller.blockChain    = BlockChain(id: "1", headBlockNumber: 1)
        
        controller.getBlocks(count: 20) { (success, error) in
            XCTAssertNotNil(error)
            XCTAssertFalse(success)
            XCTAssertEqual(controller.blocks.count, 2)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
}

class MockURLSession : DataTaskCompatible {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        completionHandler(data, response, error)
        
        return URLSession.shared.dataTask(with: request)
    }
    

}

extension Data {
    
    static func data(fromFileNamed name: String, type: String, inBundle bundle: Bundle) -> Data? {
        if let filePath = bundle.path(forResource: name, ofType: type) {
            do {
                return try Data(contentsOf: URL(fileURLWithPath: filePath))
            } catch {
                return nil
            }
        }
        return nil
    }
    
}
