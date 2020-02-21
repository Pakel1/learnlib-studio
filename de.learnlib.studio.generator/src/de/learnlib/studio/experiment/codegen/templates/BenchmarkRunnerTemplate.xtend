package de.learnlib.studio.experiment.codegen.templates

import de.learnlib.studio.experiment.codegen.GeneratorContext

class BenchmarkRunnerTemplate extends AbstractSourceTemplate {
	
	
	 new(GeneratorContext context) {
        super(context, "BenchmarkRunner")
    }
    
    override template() '''
    	package «package»;
    	public class BenchmarkRunner {
    	    public static void main(String[] args) throws Exception {
    	        org.openjdk.jmh.Main.main(args);
    	    }
    	}
    '''
}