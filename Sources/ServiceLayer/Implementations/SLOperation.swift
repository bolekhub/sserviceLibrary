//
//  SLOperation.swift
//  ServiceLayerLib
//
//  Created by Boris Chirino on 12/9/22.
//

import Foundation

    /// This class is the glue between request and dispatcher. Take the SLRequest and forward to Dispatcher for execution
final public class SLOperation: SLOperationProtocol {
    
    /// Describe what will be returned by executing request.
    public typealias Output = SLResponseProtocol?
    
    /// session task
    private var task: URLSessionTask?
    
    /// contain all parameters needed by request itself
    public var request: SLRequest
    
    public init(_ request: SLRequest) {
        self.request = request
    }
    
    public func cancel() {
        task?.cancel()
    }

    public func execute(in requestDispatcher: RequestDispatcherProtocol, completion: @escaping (SLResponseProtocol?) -> Void) {
        let baseUrl = requestDispatcher.environment.baseURL
        self.request.setBaseURL(baseUrl)
        task = requestDispatcher.execute(request: request, completion: { result in
            completion(result)
        })
    } 
}
