package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.experiment.OracleEdge
import de.learnlib.studio.experiment.experiment.ParallelOracle
import de.learnlib.studio.experiment.experiment.ParallelOracleEdge
import de.learnlib.studio.experiment.experiment.SuperOracle
import de.learnlib.studio.experiment.experiment.QSRCounterFilter
import de.learnlib.studio.experiment.experiment.SymbolCacheFilter
import de.learnlib.studio.experiment.experiment.SULSymbolQueryOracle
import de.learnlib.studio.experiment.experiment.SymbolCounterFilter
import de.learnlib.studio.experiment.experiment.SimulateSuperOracle

class SimulateSuperOracleTemplate extends AbstractSourceTemplate implements
PerNodeTemplate<SimulateSuperOracle>,OracleInformationProvider<SimulateSuperOracle>, LearnLibArtifactProvider<SimulateSuperOracle> {
	
	val SimulateSuperOracle node
	val int i		
	
	new(GeneratorContext context) {
		super(context,"")
		this.node = null
		this.i = -1
	}
	
	new(GeneratorContext context, SimulateSuperOracle node, int i) {
        super(context, "oracles", "LLS_SuperOracle")
        this.node = node
        this.i       = i
	}
	
	override getNode() {
		return node
	}
	
	override getExperimentImports() {
		 return #[package + "." + className]
	}
	
	override learnLibArtifacts() {
		 #["learnlib-membership-oracles","learnlib-drivers-simulator","learnlib-parallelism"]
	}
	
	override getConstructorParameters() {
		val delegateParallel = node.getOutgoing(ParallelOracleEdge).head.targetElement
		
		val oracle = getDelegateOracle(delegateParallel)
		
		return #[delegateParallel,oracle]
	}
	
	protected def getDelegateOracle(ParallelOracle delegateParallel) {
		val edges = delegateParallel.getOutgoing(OracleEdge)
		while(!edges.isEmpty){
			val oracle = edges.head
			if(oracle.targetElement instanceof SULSymbolQueryOracle || oracle.targetElement instanceof SymbolCacheFilter ||
				 oracle.targetElement instanceof QSRCounterFilter|| oracle.targetElement instanceof SymbolCounterFilter) 
				 return oracle.targetElement
				 
			edges.remove(edges.head)
		}
		
	}
	
	override template() '''
	package « package »;
	
	import de.learnlib.api.oracle.MembershipOracle;
	import de.learnlib.oracle.parallelism.SuperOracle;
	import de.learnlib.oracle.parallelism.StaticParallelOracle;
	import de.learnlib.oracle.parallelism.SimulatedSuperOracle;
	import net.automatalib.words.Alphabet;
		
	 public class « className » implements ExperimentSymbolOracle {
	 
	 ExperimentOracle pOracle;
	 ExperimentOracle sOracle;
	 
	 public « className »(ExperimentOracle pOracle, ExperimentOracle sOracle) {
	     	this.pOracle = pOracle;
	     	this.sOracle = sOracle;
	     	}
	     	
	 	@Override		            
	    public Alphabet getAlphabet() {
	     	return sOracle.getAlphabet();
	     }
	     	
	    @Override		            
	         public de.learnlib.api.oracle.SymbolQueryOracle getOracle() {
	         	return new SimulatedSuperOracle
	         	((de.learnlib.api.oracle.SymbolQueryOracle) sOracle.getOracle(),(StaticParallelOracle)pOracle.getOracle());
	         }
	     			            
	     @Override
	     public void postBlock() {}   
	 }
	'''
	
	
}