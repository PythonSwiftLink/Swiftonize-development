import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import PyWrapper


extension PyWrap.OptionalArg: ArgSyntax {
	public func callTupleElement(many: Bool) -> SwiftSyntax.TupleExprElementSyntax {
		switch type {
		case let other as PyWrap.OtherType:
			fatalError()
		default:
			return .optionalPyCast(arg: self, many: many)
		}
	}
	
	public func extractDecl(many: Bool) -> SwiftSyntax.VariableDeclSyntax? {
		nil
	}
	
	
}

extension PyWrap.OptionalType: ArgTypeSyntax {
	public var typeExpr: SwiftSyntax.TypeExprSyntax {
		.init(type: typeSyntax)
	}
	
	public var typeSyntax: SwiftSyntax.TypeSyntax {
		.init(OptionalTypeSyntax(wrappedType: (wrapped as! ArgTypeSyntax).typeSyntax))
	}
	
	public var typeAnnotation: SwiftSyntax.TypeAnnotationSyntax {
		.init(type: OptionalTypeSyntax(wrappedType: (wrapped as! ArgTypeSyntax).typeSyntax))
		
	}
	
	
}
