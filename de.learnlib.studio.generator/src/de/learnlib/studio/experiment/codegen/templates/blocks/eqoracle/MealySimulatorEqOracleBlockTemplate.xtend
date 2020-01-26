package de.learnlib.studio.experiment.codegen.templates.blocks.eqoracle

import de.learnlib.studio.experiment.experiment.MealySimulatorEQOracle
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.templates.blocks.BlockInterfaceTemplate
import de.learnlib.studio.experiment.codegen.templates.ExperimentDataTemplate
import de.learnlib.studio.experiment.codegen.templates.oracles.ExperimentOracleInterfaceTemplate
import de.learnlib.studio.experiment.codegen.templates.blocks.AbstractBlockInterfaceImplTemplate
import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode
import graphmodel.Edge
import graphmodel.Container
import de.learnlib.studio.experiment.experiment.SulEdge
import de.learnlib.studio.experiment.experiment.QueryEdge

class MealySimulatorEqOracleBlockTemplate extends AbstractEqBlockTemplate<MealySimulatorEQOracle> {
	
	new(GeneratorContext context) {
        super(context, "MealySimulator", "SimulatorEQOracle", "MealySimulatorEQOracle")
    }

    new(GeneratorContext context, MealySimulatorEQOracle node, int i) {
        super(context, node, i, "MealySimulator", "SimulatorEQOracle", "MealySimulatorEQOracle")
    }
				
	override getAdditionalParameters() {return #[]}
	
	 override getConstructorParameters() {
        var oracleNode = getOutgoing(QueryEdge).head.targetElement
        val sulNode = getIncoming(SulEdge).head.sourceElement
        
        
        return #[name, oracleNode, sulNode] 
    }
	
	override template() '''
	package « package »;
	
	        import java.util.Random;
	
	        import de.learnlib.api.oracle.EquivalenceOracle.MealyEquivalenceOracle;
	        import de.learnlib.api.query.DefaultQuery;
	
	        import de.learnlib.oracle.equivalence.« learnLibParentClass».« learnLibClass »;
	
	        import net.automatalib.words.Word;
	
	        import « reference(BlockInterfaceTemplate) »;
	        import « reference(ExperimentDataTemplate) »;
	        import « reference(ExperimentOracleInterfaceTemplate) »;
	        import « reference(AbstractBlockInterfaceImplTemplate) »;
	        
	    	import de.learnlib.oracle.equivalence.SimulatorEQOracle;          
	      	« val mealyPath = context.modelPackage + ".sul.ExperimentMealy"  »
	        import «  mealyPath »;
	
	
	        public class « className » implements Block {
	
	            private String blockId;
	
	            private transient final ExperimentOracle oracle;
				private ExperimentMealy mealy;
	            private transient DefaultQuery<String, Word<String>> counterExample;
	            
	            private transient Block wordSuccessor;
	            private transient Block modelSuccessor;
	            
	            public « className »(String blockId, ExperimentOracle oracle, ExperimentMealy mealy ) {
	                this.blockId = blockId;
	                this.oracle = oracle;
	                this.mealy = mealy;
	                
	            }
	            
	            public void setModelSuccessor(Block modelSuccessor) {
	                this.modelSuccessor = modelSuccessor;
	            }
	            
	            public void setWordSuccessor(Block wordSuccessor) {
	                this.wordSuccessor = wordSuccessor;
	            }
	            
	            @Override
	            public String getBlockId() {
	                return this.blockId;
	            }
	            
	            @Override
	            public String startMessage() {
	                return "Searching for a counter example with « className »(" + « FOR p : additionalParameters SEPARATOR " + \", \" + " AFTER " + " »« parameterValue(p) »« ENDFOR »")";
	            }
	            
	            @Override
	            public String endMessage() {
	                if (counterExample == null) {
	                    return "No counter example found";
	                } else {
	                    return "Found counter example " + counterExample;
	                }
	            }
	            
	            @Override
	            public Block execute(ExperimentData data) {
	            	
	                // Create a new EQ Oracle
	                SimulatorEQOracle.MealySimulatorEQOracle eqOracle = new SimulatorEQOracle.MealySimulatorEQOracle(mealy.getMealy());
	                // Counterexample Search
	                counterExample = eqOracle.findCounterExample(data.getHypothesis(), oracle.getAlphabet());
	                data.setCounterexample(counterExample);
	                
	                oracle.postBlock();
	                
	                // Next Step, depending if a Counterexample was found or not
	                System.out.println("Counter Example:" + counterExample);
	                System.out.println("\tModel Successor: " + modelSuccessor);
	                System.out.println("\tWord Successor: " + wordSuccessor);
	                if (counterExample == null) {
	                    return modelSuccessor;
	                } else {
	                    return wordSuccessor;
	                }
	            }
	            
	        }
	'''
	
	
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
	
	
}