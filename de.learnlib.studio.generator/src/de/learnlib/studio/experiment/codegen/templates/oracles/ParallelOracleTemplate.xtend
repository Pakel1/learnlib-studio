package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.experiment.ParallelOracle
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.experiment.OracleEdge
import java.util.ArrayList
import de.learnlib.studio.experiment.codegen.templates.ExperimentDataTemplate
import java.util.LinkedList
import de.learnlib.studio.experiment.experiment.Oracle

class ParallelOracleTemplate extends AbstractSourceTemplate implements
PerNodeTemplate<ParallelOracle>,OracleInformationProvider<ParallelOracle>, LearnLibArtifactProvider<ParallelOracle> {
	
	val ParallelOracle node
	val int i		
	
	new(GeneratorContext context) {
		super(context,"")
		this.node = null
		this.i = -1
	}
	
	new(GeneratorContext context, ParallelOracle node, int i
	) {
        super(context, "oracles", "ParallelOracle")
        this.node = node
        this.i       = i
	}
	
	override getNode() {
		return node
	}
	
	override getExperimentImports() {
		 return #[package + "." + className]
	}
	
	override getConstructorParameters() {
		val edges = node.getIncoming(OracleEdge)
		val oracles = new LinkedList
		while(!edges.empty){
			val oracle = edges.head.sourceElement
			edges.remove(edges.head)
			oracles.add(oracle)
		}
		return oracles
	}
	
	override learnLibArtifacts() {
		 #["learnlib-membership-oracles","learnlib-drivers-simulator", "learnlib-parallelism"]
	}
	
	override template() '''
    package « package »;
    
   import de.learnlib.api.oracle.MembershipOracle;
   import de.learnlib.oracle.parallelism.StaticParallelOracle;
   import net.automatalib.words.Alphabet;
   import java.util.ArrayList;
   import java.util.Arrays;
   import java.util.List;
    			       	        
    public class « className » implements ExperimentOracle {
    	
    	ArrayList mOracles;
    	ExperimentOracle oracle;	
    	                       
    	public « className »(ExperimentOracle... oracles) {
    		this.oracle = oracles[0];
    		mOracles = prepareMembershipOracles(oracles);
    	}
    	
    	@Override		            
    	public Alphabet getAlphabet() {
    		return oracle.getAlphabet();
    	}
    	
    	@Override		            
    	public MembershipOracle getOracle() {
    			return new new StaticParallelOracle<>(mOracles,3
    			                ,StaticParallelOracle.PoolPolicy.FIXED);
    	}
    			            
    	@Override
    	public void postBlock() {}   
    	
    	public ArrayList prepareMembershipOracles(ExperimentOracle[] pOracles){
    			ArrayList out = new ArrayList();
    			Arrays.asList(pOracles).forEach(o -> out.add(o.getOracle()));
    			return out;
    		}
    }
    		
    '''
}