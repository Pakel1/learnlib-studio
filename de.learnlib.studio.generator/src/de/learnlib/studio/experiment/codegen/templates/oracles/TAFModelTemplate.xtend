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
import de.learnlib.studio.experiment.codegen.providers.AutomataLibArtifactProvider
import de.learnlib.studio.experiment.experiment.TAFMealy

class TAFModelTemplate extends AbstractSourceTemplate implements  PerNodeTemplate<TAFMealy>,
                   LearnLibArtifactProvider<TAFMealy>,
                   MealyInformationProvider<TAFMealy>,
                   AutomataLibArtifactProvider<TAFMealy> {
                   	
    val TAFMealy node
    val Integer i
	
    
   
	new(GeneratorContext context) {
        super(context, "")
        this.node      = null
       	this.i = -1
    }
    
    new(GeneratorContext context, TAFMealy node, int i) {
        super(context, "sul", "TAFMealy" + i)
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
		package « package »;
        
         import net.automatalib.serialization.taf.parser.TAFParseDiagnosticListener;
                import net.automatalib.serialization.taf.parser.TAFParser;
                import net.automatalib.words.Alphabet;
                
                import net.automatalib.words.impl.SimpleAlphabet;
                import net.automatalib.automata.transducers.impl.compact.CompactMealy;
                
                import net.automatalib.util.automata.random.RandomAutomata;
        
                import java.io.File;
                import java.io.IOException;
                import java.util.ArrayList;
                import java.util.Random;
                
                import taf.ExperimentData;
        
        import « reference(ExperimentDataTemplate) »;
        
        public final class « className » implements ExperimentMealy {
            
            private Alphabet alphabet;
            private CompactMealy mealy;
            private ArrayList output;
            
            public « className »() {
              
           
                        mealy = TAFParser.parseMealy(new File("«node.path»"), new TAFParseDiagnosticListener() {
                            @Override
                            public void error(int line, int col, String msgFmt, Object... args) {
            
                            }
            
                            @Override
                            public void warning(int line, int col, String msgFmt, Object... args) {
            
                            }
                        });
                   
                }
            
                @Override
                public Alphabet getAlphabet() {
                    return mealy.getInputAlphabet();
                }
            
                @Override
                public CompactMealy getMealy() {
                    return mealy;
                }
            
                @Override
                public void postBlock() {}
            
            }
	'''
	
	override automataLibArtifacts() {
		#["automata-serialization-taf"]
	}
	
	override numberOfStates() {
		return 0;
	}
	
	override inputLength() {
		return 0;
	}
	
	override outputLength() {
		return 0;
	}
		
}			
