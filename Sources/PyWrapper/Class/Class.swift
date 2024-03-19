import Foundation
import PyAstParser

fileprivate var functionsExclude: [String] = [
	"__init__",
	"__getattr__",
	"__setattr__"

]
fileprivate func getFunctionOverloads(functions: [any Stmt]) -> [PyWrap.Class.ClassOverLoads] {
	functions.compactMap { stmt in
		switch stmt.type {
		case .FunctionDef:
			if let function = stmt as? AST.FunctionDef {
				return .init(rawValue: function.name)
			}
		default: return nil
		}
		return nil
	}
}
fileprivate func convertAST2Function(_ asts: [any Stmt], cls: PyWrap.Class) -> [PyWrap.Function]? {
	if asts.isEmpty { return nil }
	var out = [PyWrap.Function]()
	for ast in asts {
		switch ast.type {
		case .FunctionDef:
			if let function = ast as? AST.FunctionDef {
				if functionsExclude.contains(function.name) { continue }
				out.append(.init(ast: function, cls: cls))
			}
		default: continue
		}
	}
	return out.isEmpty ? nil : out
}


fileprivate func convertAST2Property(_ asts: [any Stmt], cls: PyWrap.Class) -> [any ClassProperty]? {
	if asts.isEmpty { return nil }
	var out = [any ClassProperty]()
	for ast in asts {
		switch ast.type {
		case .AnnAssign:
			
			out.append(PyWrap.Class.propertyFromAST(ast: ast as! AST.AnnAssign))
		case .Assign:
			out.append(PyWrap.Class.Property(stmt: ast as! AST.Assign))
		case .FunctionDef: continue
		case .ClassDef: continue
		case .Expr: continue
		default: fatalError(ast.type.rawValue)
		}
	}
	return out.isEmpty ? nil : out
}

extension AST.Constant {
	var boolValue: Bool {
		if let value = value {
			return Bool(value.lowercased()) ?? false
		}
		
		return false
	}
}

public extension PyWrap {
	
	class Class {
		
		public var functions: [Function]?
		
		public var ast: AST.ClassDef?
		
		public var properties: [any ClassProperty]?
		
		public var options: PyWrap.ClassOptions
		
		public var overloads: [ClassOverLoads] = []
		
		init(ast: AST.ClassDef) {
			self.ast = ast
			functions = []
			//print(ast.name)
			let decos = ast.decorator_list
			//print(ast.decorator_list)
			options = .init()
			if decos.isEmpty {
//
			} else {
				for deco in decos {
					switch deco.type {
					case .Call:
						if let call = deco as? AST.Call, let ast_name = call._func as? AST.Name {
							let deco_name = ast_name.id
							if deco_name == "wrapper" {
								let kws = call.keywords.compactMap { kw in
									if let arg = kw.arg, let value = (kw.value as? AST.Constant)?.value {
										return (arg,value)
									}
									return nil
								}
								for kw in kws {
									switch kw.0 {
									case "target":
										options.target = kw.1
									case "py_init":
										options.py_init = kw.1 == "True" ? true : false
									default: break
									}
								}
								for (i, arg) in call.args.enumerated() {
									switch i {
									case 0:
										options.py_init = (arg as! AST.Constant).boolValue ?? true
									default: break
									}
								}
							}
						}
					default: 
						continue
					}
				}
			}
			functions = convertAST2Function(ast.body, cls: self)
			properties = convertAST2Property(ast.body, cls: self)
			overloads.append(contentsOf: getFunctionOverloads(functions: ast.body))
			
//			functions = ast.body.compactMap({ stmt in
//				switch stmt.type {
//				case .FunctionDef:
//					if let function = stmt as? AST.FunctionDef {
//						if function.name == "__init__" { return nil }
//						return .init(ast: function)
//					}
//				default: break
//				}
//				return nil
//			})
		}
		
	}
}


public extension PyWrap.Class {
	var name: String { options.target ?? ast?.name ?? "NULL"}
	
	var init_func: PyWrap.Function? {
		for stmt in ast?.body ?? [] {
			switch stmt.type {
			case .FunctionDef:
				let f = stmt as! AST.FunctionDef
				if f.name == "__init__" {
					return convertAST2Function([f], cls: self)?.first
				}
			default: break
			}
		}
		return nil
	}
}

public extension PyWrap {
	struct ClassOptions {
		public var py_init = true
		public var debug_mode = false
		public var target: String? = nil
		
		init(py_init: Bool = false, debug_mode: Bool = false, target: String? = nil) {
			self.py_init = py_init
			self.debug_mode = debug_mode
			self.target = target
		}
		
		
	}
}


public extension PyWrap.Class {
	enum ClassOverLoads: String {
		case __getattr__
		case __setattr__
	}
}
