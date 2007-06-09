module RGen

module ECore

# Mixin to provide access to the ECore model describing a Ruby class or module
# built using MetamodelBuilder.
# The module should be used to +extend+ a class or module, i.e. to make its
# methods class methods.
# 
module ECoreInstantiator
	
	# This method will lazily build to ECore model element belonging to the calling
	# class or module using ECoreTransformer.
	# 
	def ecore
		require 'rgen/ecore/ecore_transformer'
		@@transformer ||= ECoreTransformer.new
		@@transformer.trans(self)
	end	
	
end

end

end