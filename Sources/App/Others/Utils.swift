//
//  File.swift
//  
//
//  Created by Eduardo Martin Lorenzo on 6/7/22.
//

import Vapor

/// Funcion genérica para controlar los posibles errores que se producen al convertir los datos de entrada en el objeto deseado
func decode<T:Content>(req:Request, type:T.Type) throws -> T {
    do {
        return try req.content.decode(type)
    } catch {
        throw Abort(.badRequest, reason: "JSON de entrada no válido")
    }
}
