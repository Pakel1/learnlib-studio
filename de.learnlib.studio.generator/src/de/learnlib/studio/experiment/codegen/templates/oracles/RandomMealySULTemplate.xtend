package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.providers.MealyInformationProvider
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.experiment.RandomMealySUL
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext
import java.util.LinkedList
import de.learnlib.studio.experiment.codegen.templates.ExperimentDataTemplate
import org.eclipse.emf.common.util.EList
import java.util.ArrayList

class RandomMealySULTemplate extends AbstractSourceTemplate implements  PerNodeTemplate<RandomMealySUL>,
                   LearnLibArtifactProvider<RandomMealySUL>,
                   MealyInformationProvider<RandomMealySUL> {
                   	
    val RandomMealySUL node
    val Integer i
	
	String tempOutput
	String tempInput
	Integer j
	Integer k
    
   
	new(GeneratorContext context) {
        super(context, "")
        this.node      = null
       	this.i = -1
    }
    
    new(GeneratorContext context, RandomMealySUL node, int i) {
        super(context, "sul", "RandomMealySUL" + i)
        this.node = node
        this.i = i;
    }
				
	override learnLibArtifacts() {
		#["learnlib-membership-oracles","learnlib-drivers-simulator"]
	}
				
	override getNode() {
		return node
	}
				
	override getExperimentImports() {
		return #[package + "." + className]
	}
				
	override getConstructorParameters() {
		return #[]
	}
	
	override template() '''
	« val inputs = prepareInputs(node.inputs)»
	« val outputs = prepareOutputs(node.outputs)»
	« val numberofStates = node.numberStates »
	« val randomSeed = node.randomSeed »
		package « package »;
        
        import net.automatalib.words.Alphabet;
        
        import net.automatalib.words.impl.SimpleAlphabet;
        import net.automatalib.automata.transducers.impl.compact.CompactMealy;
        
        import net.automatalib.util.automata.random.RandomAutomata;
        import java.util.ArrayList;
        import java.util.Random;
        
        import « reference(ExperimentDataTemplate) »;
        
        public final class « className » implements ExperimentMealy {
            
            private Alphabet alphabet;
            private CompactMealy mealy;
            private ArrayList output;
            
            public « className »() {
                /* Create Alphabet */
                alphabet = new SimpleAlphabet<>();
                «FOR String in : inputs»
                	alphabet.add("«in»");
                «ENDFOR»
                output = new ArrayList<>();
                 «FOR String out : outputs»
                    output.add("«out»");
                 «ENDFOR»
                mealy = RandomAutomata.randomMealy(new Random(«randomSeed»),«numberofStates», alphabet, output);   
            }
            
 			@Override
            public Alphabet getAlphabet() {
                return alphabet;
            }
            
            @Override
            public CompactMealy getMealy() {
                    return mealy;
            }
            
            @Override
            public void postBlock() {}
            
       } 	
	'''
	
	def prepareOutputs(String outputs) {
		val out = new ArrayList
		tempOutput = ""
		for( j = 0; j < outputs.length;){
			val in = outputs.substring(j,j+1)
			if (in.equals(",")){
				out.add(tempOutput)
				tempOutput = ""
			} else {
				if(j == outputs.length-1) out.add(in)
				tempOutput += in
			}
			j++
		}
		return out
	}
	
	def prepareInputs(String inputs) {
		val out = new ArrayList
		tempInput = ""
		for(k = 0; k < inputs.length;){
			val in = inputs.substring(k,k+1)
			if (in.equals(",")){
				out.add(tempInput)
				tempInput = ""
			} else{
				if(k == inputs.length-1) out.add(in)
				tempInput += in
			}
			k++
		}
		System.out.println("SIZE" + out.size)
		return out
	}
	
	override numberOfStates() {
		return node.numberStates
	}
	
	
	override outputLength(){
		return prepareOutputs(node.outputs).size
	}
	
	override inputLength() {
		return prepareInputs(node.inputs).size
	}
		
}			
