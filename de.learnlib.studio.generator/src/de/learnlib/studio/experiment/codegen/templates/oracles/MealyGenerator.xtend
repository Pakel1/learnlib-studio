package de.learnlib.studio.experiment.codegen.templates.oracles

import de.jabc.cinco.meta.core.utils.EclipseFileUtils

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.mealy.mealy.Mealy
import de.learnlib.studio.mealy.mealy.MealyTransition
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.templates.ExperimentDataTemplate
import de.learnlib.studio.experiment.experiment.MealySul
import de.learnlib.studio.experiment.codegen.providers.MealyInformationProvider

class MealyGenerator
        extends AbstractSourceTemplate
        implements 
                   PerNodeTemplate<MealySul>,
                   LearnLibArtifactProvider<MealySul>,
                   MealyInformationProvider<MealySul> {
    
    val MealySul node
    val Mealy  model
    val String modelName
    
    new(GeneratorContext context) {
        super(context, "")
        this.node      = null
        this.model     = null
        this.modelName = null    
    }
    
    new(GeneratorContext context, MealySul mealy, int i) {
        super(context, "sul", getModelName(mealy.mealyReference))
        this.node = mealy
        this.model = mealy.mealyReference
        this.modelName = getModelName(mealy.mealyReference)
    }
    
    private static def getModelName(Mealy model) {
        val fileName = EclipseFileUtils.getFileForModel(model).name
        val lastDotPosition = fileName.lastIndexOf('.')
        return fileName.substring(0, lastDotPosition)
    }
    
    def getMealyName() {
        return modelName
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
        « val mealyStates      = model.mealyStates »
        « val mealyInitState   = mealyStates.filter[s | s.init].get(0) »
        « val mealyTranstitons = model.getEdges(MealyTransition) »
        package « package »;
        
        import net.automatalib.words.Alphabet;
        
        import net.automatalib.words.impl.SimpleAlphabet;
        import net.automatalib.automata.transducers.impl.compact.CompactMealy;
        
        import « reference(ExperimentDataTemplate) »;
        
        
        public final class « className » implements ExperimentMealy {
            
            private Alphabet alphabet;
            private CompactMealy mealy;
            
            
            public « className »() {
                /* Create Alphabet */
                alphabet = new SimpleAlphabet<>();
                « FOR i : mealyTranstitons.map[e | e.input].toSet »
                    alphabet.add("« i »");
                « ENDFOR »
                
                /* Create Melay */
                mealy = new CompactMealy<>(alphabet, « mealyStates.size »);
                mealy.setInitialState(« mealyStates.indexOf(mealyInitState) »);
                « FOR t : mealyTranstitons »
                    « val sourceElement = mealyStates.indexOf(t.sourceElement) »
                    « val targetElement = mealyStates.indexOf(t.targetElement) »
                    mealy.addTransition(« sourceElement », "« t.input »", « targetElement », "« t.output »");
                « ENDFOR »
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
}
