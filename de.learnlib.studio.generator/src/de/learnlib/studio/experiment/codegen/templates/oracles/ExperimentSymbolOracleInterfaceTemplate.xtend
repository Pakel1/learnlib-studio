package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.experiment.Oracle

class ExperimentSymbolOracleInterfaceTemplate
        extends AbstractSourceTemplate
        implements LearnLibArtifactProvider<Oracle> {
	
	new(GeneratorContext context) {
		super(context, "oracles", "ExperimentSymbolOracle")
	}
	
	override learnLibArtifacts() {
        #["learnlib-membership-oracles"]
    }
    
	override template() '''
		package « package »;
		
		import de.learnlib.api.oracle.SymbolQueryOracle;
		
		
		public interface « className » extends ExperimentOracle {
			
			@Override
			SymbolQueryOracle getOracle();
			
		}
	'''
	
}
