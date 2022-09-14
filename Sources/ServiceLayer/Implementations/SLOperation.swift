//
//  SLOperation.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

    /// This class is the glue between request and dispatcher. Take the SLRequest and forward to Dispatcher for execution
final class SLOperation: SLOperationProtocol {
    
    /// Describe what will be returned by executing request.
    typealias Output = SLResponseProtocol?
    
    /// session task
    private var task: URLSessionTask?
    
    /// contain all parameters needed by request itself
    var request: SLRequest
    
    init(_ request: SLRequest) {
        self.request = request
    }
    
    func cancel() {
        task?.cancel()
    }

    func execute(in requestDispatcher: RequestDispatcherProtocol, completion: @escaping (SLResponseProtocol?) -> Void) {
        let baseUrl = requestDispatcher.environment.baseURL
        self.request.setBaseURL(baseUrl)
        task = requestDispatcher.execute(request: request, completion: { result in
            completion(result)
        })
    } 
}
