package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.experiment.SymbolCounterFilter
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.GeneratorContext

import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode
import de.learnlib.studio.experiment.experiment.QueryEdge
import graphmodel.Container
import graphmodel.Edge
import de.learnlib.studio.experiment.codegen.templates.utils.ResultWriterTemplate

class SymbolCounterFilterTemplate extends AbstractSourceTemplate implements PerNodeTemplate<SymbolCounterFilter>,
OracleInformationProvider<SymbolCounterFilter>, LearnLibArtifactProvider<SymbolCounterFilter> {
	
	val SymbolCounterFilter filter
    val int i

    new(GeneratorContext context) {
        this(context, null, -1)
    }

    new(GeneratorContext context, SymbolCounterFilter filter, int i) {
        super(context, "oracles", "SymbolCounter")
        this.filter  = filter
        this.i       = i
	}
	
	override learnLibArtifacts() {
        return #["learnlib-statistics"]
    }
	
	override getConstructorParameters() {
        val delegateNode = getOutgoing(QueryEdge).head.targetElement
        return #[delegateNode]
    }
    
    def <T extends Edge> getOutgoing(Class<T> clazz) {
        if (node.isChildOfAComplexNode) {
        	val successors = node.getOutgoing(clazz)
        	if (successors.empty) {
            	val container = node.container as Container
            	return container.getOutgoing(clazz)
        	} else {
        		return successors
        	}
        } else {
            return node.getOutgoing(clazz)
        }
    }
    
    override getExperimentImports() {
        return #[package + "." + className]
    }
    
    override getName() {
        return "counter" + i
    }

    override getNode() {
        return filter
    }
	
	override template() '''
	 package « package »;
	
	 import java.nio.file.Path;
	
	 import net.automatalib.words.Alphabet;
	 import de.learnlib.api.oracle.SymbolQueryOracle;
	 import de.learnlib.filter.statistic.oracle.CounterSymbolQueryOracle;
	       
	 import « reference(ResultWriterTemplate) »;
	
	 public class « className » implements ExperimentSymbolOracle {
	
	    private ExperimentSymbolOracle delegate;
	    private CounterSymbolQueryOracle oracle;
	            
	    private long prevSymbolSum;
	    private long prevResetSum;
	    private int stepCount;
	    private String name;
	
	     public « className»(ExperimentSymbolOracle delegate) {
	         this.delegate = delegate;
	         this.oracle = new CounterSymbolQueryOracle(delegate.getOracle());
	         this.name = "SymbolCounter";
	         this.prevSymbolSum = 0;
	         this.prevResetSum = 0;
	         this.stepCount = 0;
	      }
	      
	 public Alphabet getAlphabet() {
	        return delegate.getAlphabet();
	 }
	            
	 public SymbolQueryOracle getOracle() {
	     return oracle;
	 }
	 
	 @Override
	 public void postBlock() {
	     long realSymbolCount = oracle.getSymbolCount() - prevSymbolSum;
	     long realResetCount = oracle.getResetCount() - prevResetSum;
	                 
	                 System.out.println("Symbol Counter " + ": " + realSymbolCount);
	                 System.out.println("Reset Counter " + ": " + realResetCount);
	                 try {
	                     ResultWriter.writeData(this.name, this.stepCount, Long.toString(realSymbolCount));
	                     ResultWriter.writeData(this.name, this.stepCount, Long.toString(realResetCount));
	                     
	                 } catch(Exception e) {
	                     e.printStackTrace();
	                 }
	                 
	                 prevSymbolSum = oracle.getSymbolCount();
	                 prevResetSum = oracle.getResetCount();
	                 stepCount++;
	             }
	 
	             
	             public void dispose() {
	                 System.out.println("Symbol Counter " +  "(sum): " + oracle.getSymbolCount());
	                 ResultWriter.writeData(this.name, "sum", Long.toString(oracle.getSymbolCount()));
	                 System.out.println("Symbol Counter " +  "(sum): " + oracle.getResetCount());
	                 ResultWriter.writeData(this.name, "sum", Long.toString(oracle.getResetCount()));
	                 delegate = null;
	             }
	             
	         }
	'''
		
	
	
}