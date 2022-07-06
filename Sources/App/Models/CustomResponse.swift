//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 6/7/22.
//

import Vapor


struct CustomResponse<T:Content> {    
    
    var httpResponse: Response
    var data: T
    var error: String?
    
    init(httpResponse:Response, data: T, errorMessage: String?) {
        self.httpResponse = httpResponse
        self.data = data
        if let error = errorMessage {
            self.error = error
        }
    }
    
    init(httpResponse:Response, data: T) {
        self.httpResponse = httpResponse
        self.data = data
    }
    
}
