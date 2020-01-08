package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.experiment.QSRCounterFilter
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.experiment.QueryEdge

import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode
import graphmodel.Container
import graphmodel.Edge
import de.learnlib.studio.experiment.codegen.templates.utils.ResultWriterTemplate

class QSRCounterFilterTemplate extends AbstractSourceTemplate
        implements PerNodeTemplate<QSRCounterFilter>,
                   OracleInformationProvider<QSRCounterFilter>,
                   LearnLibArtifactProvider<QSRCounterFilter> {

    val QSRCounterFilter filter
    val int i

    new(GeneratorContext context) {
        this(context, null, -1)
    }

    new(GeneratorContext context, QSRCounterFilter filter, int i) {
        super(context, "oracles", "QSRCounter")
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
    
    override template()'''
    package « package »;
    
     import de.learnlib.api.oracle.MembershipOracle;
     import de.learnlib.filter.statistic.oracle.CounterQueryOracle;
     import net.automatalib.words.Alphabet;  
      import « reference(ResultWriterTemplate) »;
      
      public class « className » implements ExperimentOracle {
      	
        private ExperimentOracle delegate;
        private CounterQueryOracle oracle;
                  
        private long prevSymbolSum;
        private long prevResetSum;
        private long prevQuerySum;
        private int  stepCount;
        private String name;
      	
      	public « className»(ExperimentOracle delegate) {
      		this.name = "QSRCounter";
      		this.delegate = delegate;
      		this.oracle = new CounterQueryOracle((de.learnlib.api.oracle.SymbolQueryOracle)delegate.getOracle());
      		this.prevSymbolSum = 0;
      		this.prevResetSum = 0;
      		this.prevQuerySum = 0;
      		this.stepCount = 0;	
      }
      
        public Alphabet getAlphabet() {
            return delegate.getAlphabet();
        }
        
        public MembershipOracle getOracle(){
        	return oracle;
        }
        
        @Override
        	 public void postBlock() {
        	     long realSymbolCount = oracle.getSymbolCount() - prevSymbolSum;
        	     long realResetCount = oracle.getResetCount() - prevResetSum;
        	     long realQueryCount = oracle.getQueryCount() - prevQuerySum;
        	                 
        	                 System.out.println("Symbol Counter " + ": " + realSymbolCount);
        	                 System.out.println("Reset Counter " + ": " + realResetCount);
        	                  System.out.println("Query Counter " + ": " + realQueryCount);
        	                 try {
        	                     ResultWriter.writeData(this.name, this.stepCount, Long.toString(realSymbolCount));
        	                     ResultWriter.writeData(this.name, this.stepCount, Long.toString(realResetCount));
        	                     ResultWriter.writeData(this.name, this.stepCount, Long.toString(realQueryCount));
        	                     
        	                 } catch(Exception e) {
        	                     e.printStackTrace();
        	                 }
        	                 
        	                 prevSymbolSum = oracle.getSymbolCount();
        	                 prevResetSum = oracle.getResetCount();
        	                 prevQuerySum = oracle.getQueryCount();
        	                 stepCount++;
        	             }
        	 
        	             
        	             public void dispose() {
        	                 System.out.println("Symbol Counter " +  "(sum): " + oracle.getSymbolCount());
        	                    	                 System.out.println("Reset Counter " +  "(sum): " + oracle.getResetCount());
        	                    	                 System.out.println("Query Counter " +  "(sum): " + oracle.getQueryCount());
        	                						 ResultWriter.writeData(this.name, "sum", Long.toString(oracle.getSymbolCount()));
        	                						 ResultWriter.writeData(this.name, "sum", Long.toString(oracle.getResetCount()));
        	                    	                 ResultWriter.writeData(this.name, "sum", Long.toString(oracle.getQueryCount()));
        	                    	                 delegate = null;
        	             }
        	             
        
     }
      
    	
    '''
	
}