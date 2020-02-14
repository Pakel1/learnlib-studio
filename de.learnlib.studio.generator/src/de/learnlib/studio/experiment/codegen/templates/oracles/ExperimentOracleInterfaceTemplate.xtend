package de.learnlib.studio.experiment.codegen.templates.oracles

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.templates.AbstractSourceTemplate
import de.learnlib.studio.experiment.codegen.providers.LearnLibArtifactProvider
import de.learnlib.studio.experiment.experiment.Oracle


class ExperimentOracleInterfaceTemplate
        extends AbstractSourceTemplate
        implements LearnLibArtifactProvider<Oracle> {
	
	new(GeneratorContext context) {
		super(context, "oracles", "ExperimentOracle")
	}
	
	override learnLibArtifacts() {
        return #["learnlib-membership-oracles", "learnlib-statistics", "learnlib-parallelism"]
    }
    
	override template() '''
		package « package »;
		
		import net.automatalib.words.Alphabet;
		import de.learnlib.api.oracle.MembershipOracle;
		
		
		public interface « className » {
			
			Alphabet getAlphabet();
			
			MembershipOracle getOracle();
			
			void postBlock();
			
		}
	'''
	
}
