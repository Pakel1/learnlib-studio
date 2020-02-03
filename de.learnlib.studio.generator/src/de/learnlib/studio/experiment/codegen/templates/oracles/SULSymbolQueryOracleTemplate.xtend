package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.experiment.SULSymbolQueryOracle
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.GeneratorContext

import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode
import graphmodel.Edge
import graphmodel.Container
import de.learnlib.studio.experiment.experiment.SulEdge
import de.learnlib.studio.experiment.experiment.MealySul
import de.learnlib.studio.experiment.codegen.templates.ExperimentDataTemplate

class SULSymbolQueryOracleTemplate extends AbstractSourceTemplate implements
PerNodeTemplate<SULSymbolQueryOracle>,
OracleInformationProvider<SULSymbolQueryOracle>,
LearnLibArtifactProvider<SULSymbolQueryOracle>  {
	
	val SULSymbolQueryOracle oracle
	val int i		
	
	new(GeneratorContext context) {
		super(context,"")
		this.oracle=null
		this.i = -1
	}
	
	new(GeneratorContext context, SULSymbolQueryOracle oracle, int i) {
        super(context, "oracles", "LLS_SymbolQueryOracle")
        this.oracle = oracle
        this.i       = i
	}
	
	override getNode() {
		return oracle
	}
	
	override getName(){
		return "SymbolQueryOracle" + i;
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
		 #["learnlib-membership-oracles","learnlib-drivers-simulator", "learnlib-statistics", "learnlib-parallelism"]
	}
	

    
    override template() '''
    package « package »;
    
     «  val mealy = context.modelPackage + ".sul.ExperimentMealy"  »
       import «  mealy »;
    			        
   import de.learnlib.driver.util.MealySimulatorSUL;
   import de.learnlib.oracle.membership.SULSymbolQueryOracle;
   
   import net.automatalib.words.Alphabet;
   
    import « reference(ExperimentDataTemplate) »;
    			       	        
    public class « className » implements ExperimentSymbolOracle {
    	
    	ExperimentMealy mealy;		                       
    	public « className »(ExperimentMealy mealy) {
    		this.mealy = mealy;
    	}
    			            
    	public Alphabet getAlphabet() {
    		return mealy.getAlphabet();
    	}
    			            
    	public de.learnlib.api.oracle.SymbolQueryOracle getOracle() {
    			return new SULSymbolQueryOracle<>(new MealySimulatorSUL<>(mealy.getMealy()));
    	}
    			            
    	@Override
    	public void postBlock() {}   
    }
    		
    '''
}