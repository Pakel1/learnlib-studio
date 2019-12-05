package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.GeneratorContext

class ExperimentMealyInterfaceTemplate extends AbstractSourceTemplate {
	
	new(GeneratorContext context) {
		super(context, "sul", "ExperimentMealy")
	}
	
	override template() '''
	package « package »;
	
	import net.automatalib.automata.transducers.impl.compact.CompactMealy;
	import net.automatalib.words.Alphabet;
	
	public interface « className » {
				
		Alphabet getAlphabet();
				
		CompactMealy getMealy();
				
		void postBlock();
				
	}
	'''
		
	
	
}