

import Foundation
import PyAstParser


public extension PyWrap {
	
	struct DataType: TypeProtocol, CustomStringConvertible {
		public static func fromAST(ast: PyAstParser.AST.Name, type: PythonType) -> PyWrap.BoolType {
			fatalError()
		}
		public init(from ast: AST.Name, type: PythonType) {
			self.ast = ast
			self.py_type = type
		}
		
		public var ast: AstType?
		
		public typealias AstType = AST.Name
		
		public var py_type: PythonType
		
		init(ast: PyAstParser.AST.Name, py_type: PythonType) {
			self.ast = ast
			self.py_type = py_type
			
		}
		
		public static func fromAST(_ ast: PyAstParser.AST.Name, type: PythonType) -> any TypeProtocol {
			Self.init(ast: ast, py_type: type)
		}
		
		public var description: String { "Bool" }
		
	}
	
}

