package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.experiment.SuperOracle
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.experiment.ParallelOracleEdge
import de.learnlib.studio.experiment.experiment.OracleEdge

class SuperOracleTemplate extends AbstractSourceTemplate implements
PerNodeTemplate<SuperOracle>,OracleInformationProvider<SuperOracle>, LearnLibArtifactProvider<SuperOracle> {
	
	val SuperOracle node
	val int i		
	
	new(GeneratorContext context) {
		super(context,"")
		this.node = null
		this.i = -1
	}
	
	new(GeneratorContext context, SuperOracle node, int i) {
        super(context, "oracles", "SuperOracle")
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
		 #["learnlib-membership-oracles","learnlib-drivers-simulator", "learnlib-parallelism"]
	}
	
	override getConstructorParameters() {
		val delegateParallel = node.getOutgoing(ParallelOracleEdge).head.targetElement
		val delegateOracle = node.getOutgoing(OracleEdge).head.targetElement
		return #[delegateParallel,delegateOracle]
	}
	
	override template() '''
	package « package »;
	
	import de.learnlib.api.oracle.MembershipOracle;
	import de.learnlib.oracle.parallelism.StaticParallelOracle;
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
	         	return new de.learnlib.oracle.parallelism.SuperOracle
	         	((de.learnlib.api.oracle.SymbolQueryOracle) sOracle.getOracle(),(StaticParallelOracle)pOracle.getOracle());
	         }
	     			            
	     @Override
	     public void postBlock() {}   
	 }
	'''
	
	
}