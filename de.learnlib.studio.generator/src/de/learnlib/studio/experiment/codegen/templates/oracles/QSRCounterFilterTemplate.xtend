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
        super(context, "oracles", "QSRCounter" + i )
        this.filter  = filter
        this.i       = i
	}
	
    override learnLibArtifacts() {
       return #["learnlib-statistics"]
    }
    
    override getConstructorParameters() {
        val delegateNode = getOutgoing(QueryEdge).head.targetElement
        return #[delegateNode, node.name]
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
        return "QSRCounter" + i
    }

    override getNode() {
        return filter
    } 
    
    override template()'''
    package « package »;
    
     import de.learnlib.api.oracle.SymbolQueryOracle;
     import de.learnlib.api.oracle.MembershipOracle;
     import de.learnlib.filter.statistic.oracle.CounterQueryOracle;
     import net.automatalib.words.Alphabet;  
      import « reference(ResultWriterTemplate) »;
      
      public class « className » implements ExperimentSymbolOracle {
      	
        private ExperimentSymbolOracle delegate;
        private CounterQueryOracle oracle;
                  
        private long prevSymbolSum;
        private long prevResetSum;
        private long prevQuerySum;
        private int  stepCount;
        private String name = "« className »";
      	
      	public « className»(ExperimentSymbolOracle delegate, String name) {
      		if(!name.equals("")) this.name=name;
      		this.delegate = delegate;
      		this.oracle = new CounterQueryOracle(delegate.getOracle());
      		this.prevSymbolSum = 0;
      		this.prevResetSum = 0;
      		this.prevQuerySum = 0;
      		this.stepCount = 0;	
      }
      
        public Alphabet getAlphabet() {
            return delegate.getAlphabet();
        }
        
        public SymbolQueryOracle getOracle(){
        	return oracle;
        }
        
        public String getName(){
        	return name;
        	}
        
        @Override
       	 public void postBlock() {}
        	 
        	             
        	             public void dispose() {
        	                 System.out.println("Symbol Counter " +  "(sum): " + oracle.getSymbolCount());
        	                    	                 System.out.println("Reset Counter " +  "(sum): " + oracle.getResetCount());
        	                    	                 System.out.println("Query Counter " +  "(sum): " + oracle.getQueryCount());
        	                						 ResultWriter.writeData(this.name, "Symbols", Long.toString(oracle.getSymbolCount()));
        	                						 ResultWriter.writeData(this.name, "Resets", Long.toString(oracle.getResetCount()));
        	                    	                 ResultWriter.writeData(this.name, "Queries", Long.toString(oracle.getQueryCount()));
        	                    	                 delegate = null;
        	             }
        	             
        public String getCounts(){
        	StringBuffer out = new StringBuffer();
        	    	out.append(oracle.getSymbolCount());
        	    	out.append(";");
        	        out.append(oracle.getResetCount());
        	        out.append(";");
        	        out.append(oracle.getBatchCount());
        	        out.append(";");
        	        out.append(oracle.getAverageBatchSize());
        	        out.append(";");
        	        out.append(oracle.getSymbolCount());
        	        out.append(";");
        	        out.append(oracle.getResetCount());
        	    	return out.toString();
        }
        	             
        
     }
      
    	
    '''
	
}