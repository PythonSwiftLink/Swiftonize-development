//
//  File.swift
//  
//
//  Created by CodeBuilder on 13/02/2024.
//

import Foundation
import PyWrapper
import PyAstParser

extension PyWrap.Class {
	
	func bases() -> [WrapClassBase] {
		if let bases = ast?.decorator_list.contains(where: { deco in
			if let call = deco as? AST.Call {
				return (call._func as? AST.Name)?.id == "bases"
			}
			return false
		}) {
			for deco in ast?.decorator_list ?? [] {
				if let call = deco as? AST.Call, (call._func as! AST.Name).id == "bases" {
					return call.args.compactMap({$0 as! AST.Name}).compactMap({
						WrapClassBase(rawValue: $0.id)
					})
				}
			}
		}
		return ast?.bases.compactMap({ expr in
			if let name = expr as? AST.Name {
				return WrapClassBase(rawValue: name.id)
			}
			return nil
		}) ?? []
	}
}
