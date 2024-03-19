import Foundation
import PyAstParser


public struct PyWrap {
	
	public static func parse(file: URL) throws -> Module {
		.init(ast: try AST.parseFile(url: file))
	}
	public static func parse(string: String) throws -> Module {
		.init(ast: try AST.parseString(string))
	}
	private init() {}
}

public extension PyWrap {
	class Module {
		
		public var filename: String
		public var classes: [Class]
		public var functions: [Function]
		
		
		init(ast: AST.Module) {
			
			filename = ast.name
			classes = ast.body.compactMap { stmt in
				let stmt_type = stmt.type
				switch stmt_type {
				case .ClassDef:
					if let cls = stmt as? AST.ClassDef {
						let decos = cls.decorator_list
						for deco in decos {
							switch deco.type {
							case .Call:
								if let call = deco as? AST.Call, let ast_name = call._func as? AST.Name {
									let deco_name = ast_name.id
									switch deco_name {
									case "wrapper":
//										print(call.keywords.map{($0.arg!, $0.value.type.rawValue)})
//										print(call.args.compactMap({$0 as? AST.Constant}).compactMap(\.value))
										return PyWrap.fromAST(cls)
									default: break
									}
								}
							default:
								continue
								//options = .init()
								//fatalError(deco.type.rawValue)
							}
						}

						return nil
					}
				default: break
				}
				
				return nil
			}
			functions = ast.body.compactMap({ stmt in
				let stmt_type = stmt.type
				switch stmt_type {
				case .FunctionDef:
					if let function = stmt as? AST.FunctionDef {
						return Function(ast: function)
					}
				default: break
				}
				
				return nil
			})
			
		}
		
	}
	
	
	static func fromAST(_ ast: AST.ClassDef) -> Class {
		
		.init(ast: ast)
		
		
	}
}
