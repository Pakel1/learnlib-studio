package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.experiment.SymbolCacheFilter
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext
import graphmodel.Edge
import graphmodel.Container

import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode
import de.learnlib.studio.experiment.experiment.QueryEdge

class SymbolCacheFilterTemplate extends AbstractSourceTemplate
		implements PerNodeTemplate<SymbolCacheFilter>, OracleInformationProvider<SymbolCacheFilter>, 
		LearnLibArtifactProvider<SymbolCacheFilter> {
	
	val SymbolCacheFilter filter
	val int i		
			
	new(GeneratorContext context) {
		this(context, null, -1)
	}
	
	new(GeneratorContext context, SymbolCacheFilter filter, int i) {
        super(context, "oracles", "SymbolOracleCache")
        this.filter  = filter
        this.i       = i
	}
	
	override getNode() {
		return filter
	}
			
	override getName() {
		return "cache" + i
	}
				
	override getExperimentImports() {
		 return #[package + "." + className]
	}
			
	override getConstructorParameters() {
		val delegateNode = getOutgoing(QueryEdge).head.targetElement
       	return #[delegateNode]
	}
			
	override learnLibArtifacts() {
		return #["learnlib-cache"]
	}

	def <T extends Edge> getOutgoing(Class<T> clazz) {
        if (node.isChildOfAComplexNode) {
        	val successor = node.getOutgoing(clazz)
        	if (successor === null) {
            	val container = node.container as Container
            	return container.getOutgoing(clazz)
        	} else {
        		return successor
        	}
        } else {
            return node.getOutgoing(clazz)
        }
    }
    
    		
	override template() '''
	package « package »;
	        
	import net.automatalib.words.Alphabet;
	import de.learnlib.api.oracle.SymbolQueryOracle;
	        
	import de.learnlib.filter.cache.mealy.SymbolQueryCache;
	        
	        
	public class « className » implements ExperimentSymbolOracle {
	            
	   private ExperimentSymbolOracle delegate;
	            
	            
	    public « className »(ExperimentSymbolOracle delegate) {
	        this.delegate = delegate;
	    }
	            
	    public Alphabet getAlphabet() {
	        return delegate.getAlphabet();
	     }
	            
	     public SymbolQueryOracle getOracle() {
	        return new SymbolQueryCache<>(delegate.getOracle(), delegate.getAlphabet());
	     }
	            
	     @Override
	     public void postBlock() {}   
	        }
	'''
		
	
			
	
}