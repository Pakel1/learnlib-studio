package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.experiment.MealyMembershipOracle
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.experiment.SulEdge
import de.learnlib.studio.experiment.codegen.templates.ExperimentDataTemplate
import graphmodel.Edge
import graphmodel.Container
import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode

class MealyMembershipOracleTemplate extends AbstractSourceTemplate implements
PerNodeTemplate<MealyMembershipOracle>,OracleInformationProvider<MealyMembershipOracle>, LearnLibArtifactProvider<MealyMembershipOracle> {
	
	val MealyMembershipOracle node
	val int i		
	
	new(GeneratorContext context) {
		super(context,"")
		this.node = null
		this.i = -1
	}
	
	new(GeneratorContext context, MealyMembershipOracle node, int i
	) {
        super(context, "oracles", "MealyMembershipOracle" + i)
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
		val SulNode = getIncoming(SulEdge).head.sourceElement
		return #[SulNode]
	}
	
	def <T extends Edge> getIncoming(Class<T> clazz) {
        if (node.isChildOfAComplexNode) {
        	val successors = node.getIncoming(clazz)
        	if (successors.empty) {
            	val container = node.container as Container
            	return container.getIncoming(clazz)
        	} else {
        		return successors
        	}
        } else {
            return node.getIncoming(clazz)
        }
    }
	
	override learnLibArtifacts() {
		 #["learnlib-membership-oracles","learnlib-drivers-simulator"]
	}
	
	override template() '''
    package « package »;
    «  val mealy = context.modelPackage + ".sul.ExperimentMealy"  »
   import «  mealy »;
   import de.learnlib.api.oracle.MembershipOracle;
   import de.learnlib.oracle.membership.SimulatorOracle;
   import net.automatalib.words.Alphabet;
   
    import « reference(ExperimentDataTemplate) »;
    			       	        
    public class « className » implements ExperimentOracle {
    	
    	ExperimentMealy mealy;		                       
    	public « className »(ExperimentMealy mealy) {
    		this.mealy = mealy;
    	}
    	
    	@Override		            
    	public Alphabet getAlphabet() {
    		return mealy.getAlphabet();
    	}
    	
    	@Override		            
    	public MembershipOracle getOracle() {
    			return new SimulatorOracle<>(mealy.getMealy());
    	}
    			            
    	@Override
    	public void postBlock() {}   
    }
    		
    '''
	
	
	
}