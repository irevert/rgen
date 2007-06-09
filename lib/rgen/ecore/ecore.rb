require 'rgen/metamodel_builder'

module RGen
extend RGen::ECore::ECoreInstantiator

# This is the ECore metamodel described using the RGen::MetamodelBuilder language.
#
# Known differences to the Java/EMF implementation are:
# * Attributes can not be "many"
# 
module ECore
	 extend RGen::ECore::ECoreInstantiator

   class EObject < RGen::MetamodelBuilder::MMBase
   end

   class EModelElement < RGen::MetamodelBuilder::MMBase
   end

   class EAnnotation < EModelElement
      has_attr 'source', String
   end

   class ENamedElement < EModelElement
      has_attr 'name', String
   end

   class ETypedElement < ENamedElement
      has_attr 'lowerBound', Integer, :defaultValueLiteral => "0"
      has_attr 'ordered', Boolean, :defaultValueLiteral => "true"
      has_attr 'unique', Boolean, :defaultValueLiteral => "true"
      has_attr 'upperBound', Integer, :defaultValueLiteral => "1"
      has_attr 'many', Boolean, :derived=>true
      def many_derived
      	upperBound > 1 || upperBound == -1
      end
      has_attr 'required', Boolean, :derived=>true
      def required_derived
      	lowerBound > 0
      end
   end

   class EStructuralFeature < ETypedElement
      has_attr 'changeable', Boolean, :defaultValueLiteral => "true"
      has_attr 'defaultValue', Object, :derived=>true
      def defaultValue_derived
        eval(defaultValueLiteral) unless defaultValueLiteral.nil?
      end
      has_attr 'defaultValueLiteral', String
      has_attr 'derived', Boolean, :defaultValueLiteral => "false"
      has_attr 'transient', Boolean, :defaultValueLiteral => "false"
      has_attr 'unsettable', Boolean, :defaultValueLiteral => "false"
      has_attr 'volatile', Boolean, :defaultValueLiteral => "false"
   end

   class EAttribute < EStructuralFeature
      has_attr 'iD', Boolean, :defaultValueLiteral => "false"
   end

   class EClassifier < ENamedElement
      has_attr 'defaultValue', Object, :derived=>true
      has_attr 'instanceClass', Object, :derived=>true
      def instanceClass_derived
      	map = {"java.lang.String" => "String", "boolean" => "Boolean", "int" => "Integer"}
      	icn = instanceClassName
      	icn = "NilClass" if icn.nil?
      	icn = map[icn] if map[icn]
        eval(icn)
      end
      has_attr 'instanceClassName', String
   end

   class EDataType < EClassifier
      has_attr 'serializable', Boolean
   end

   class EEnum < EDataType
   end

   class EEnumLiteral < ENamedElement
			# instance may point to a "singleton object" (e.g. a Symbol) representing the literal
#      has_attr 'instance', Object, :eType=>:EEnumerator, :transient=>true
      has_attr 'literal', String
      has_attr 'value', Integer
   end
	
	 # TODO: check if required
   class EFactory < EModelElement
   end

   class EOperation < ETypedElement
   end

   class EPackage < ENamedElement
      has_attr 'nsPrefix', String
      has_attr 'nsURI', String
   end

   class EParameter < ETypedElement
   end

   class EReference < EStructuralFeature
      has_attr 'container', Boolean, :derived=>true
      has_attr 'containment', Boolean, :defaultValueLiteral => "false"
      has_attr 'resolveProxies', Boolean, :defaultValueLiteral => "true"
   end

   class EStringToStringMapEntry < RGen::MetamodelBuilder::MMBase
      has_attr 'key', String
      has_attr 'value', String
   end

   class EClass < EClassifier
      has_attr 'abstract', Boolean
      has_attr 'interface', Boolean
		has_one  'eIDAttribute', ECore::EAttribute, :derived=>true, :resolveProxies=>false
		
		has_many 'eAllAttributes', ECore::EAttribute, :derived=>true
		def eAllAttributes_derived
			eAttributes + eSuperTypes.eAllAttributes
		end
		
		has_many 'eAllContainments', ECore::EReference, :derived=>true
		def eAllContainments_derived
			eReferences.select{|r| r.containment} + eSuperTypes.eAllContainments
		end
		
		has_many 'eAllOperations', ECore::EOperation, :derived=>true
		
		has_many 'eAllReferences', ECore::EReference, :derived=>true
		def eAllReferences_derived
			eReferences + eSuperTypes.eAllReferences
		end
		
		has_many 'eAllStructuralFeatures', ECore::EStructuralFeature, :derived=>true
		def eAllStructuralFeatures_derived
			eStructuralFeatures + eSuperTypes.eAllStructuralFeatures
		end
		
		has_many 'eAllSuperTypes', ECore::EClass, :derived=>true
		def eAllSuperTypes_derived
			eSuperTypes + eSuperTypes.eAllSuperTypes
		end
		
		has_many 'eAttributes', ECore::EAttribute, :derived=>true
		def eAttributes_derived
			eStructuralFeatures.select{|f| f.is_a?(EAttribute)}
		end
		
		has_many 'eReferences', ECore::EReference, :derived=>true
		def eReferences_derived
			eStructuralFeatures.select{|f| f.is_a?(EReference)}
		end
   end
   
  # predefined datatypes

	EString = EDataType.new
	EString.name = "EString"
	EString.instanceClassName = "String"
	
	EInt = EDataType.new
	EInt.name = "EInt"
	EInt.instanceClassName = "Integer"
	
	EBoolean = EDataType.new
	EBoolean.name = "EBoolean"
	EBoolean.instanceClassName = "Boolean"
	
	EFloat = EDataType.new
	EFloat.name = "EFloat"
	EFloat.instanceClassName = "Float"

	ERubyObject = EDataType.new
	ERubyObject.name = "ERubyObject"
	ERubyObject.instanceClassName = "Object"
	
	EJavaObject = EDataType.new
	EJavaObject.name = "EJavaObject"
	
	ERubyClass = EDataType.new
	ERubyClass.name = "ERubyClass"
	ERubyClass.instanceClassName = "Class"
	
	EJavaClass = EDataType.new
	EJavaClass.name = "EJavaClass"
	
end

ECore::EModelElement.contains_many 'eAnnotations', ECore::EAnnotation, 'eModelElement', :resolveProxies=>false
ECore::EAnnotation.contains_many_uni 'details', ECore::EStringToStringMapEntry, :resolveProxies=>false
ECore::EAnnotation.contains_many_uni 'contents', ECore::EObject, :resolveProxies=>false
ECore::EAnnotation.has_many 'references', ECore::EObject
ECore::EPackage.contains_many 'eClassifiers', ECore::EClassifier, 'ePackage'
ECore::EPackage.contains_many 'eSubpackages', ECore::EPackage, 'eSuperPackage'
ECore::ETypedElement.has_one 'eType', ECore::EClassifier
ECore::EClass.contains_many 'eOperations', ECore::EOperation, 'eContainingClass', :resolveProxies=>false
ECore::EClass.contains_many 'eStructuralFeatures', ECore::EStructuralFeature, 'eContainingClass', :resolveProxies=>false
ECore::EClass.has_many 'eSuperTypes', ECore::EClass
ECore::EEnum.contains_many 'eLiterals', ECore::EEnumLiteral, 'eEnum', :resolveProxies=>false
ECore::EFactory.one_to_one 'ePackage', ECore::EPackage, 'eFactoryInstance', :lowerBound=>1, :transient=>true, :resolveProxies=>false
ECore::EOperation.contains_many 'eParameters', ECore::EParameter, 'eOperation', :resolveProxies=>false
ECore::EOperation.has_many 'eExceptions', ECore::EClassifier
ECore::EReference.has_one 'eOpposite', ECore::EReference

ECore::EAttribute.has_one 'eAttributeType', ECore::EDataType, :lowerBound=>1, :derived=>true
ECore::EReference.has_one 'eReferenceType', ECore::EClass, :lowerBound=>1, :derived=>true

end