package de.learnlib.studio.experiment.codegen.templates

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.templates.config.CommandLineOptionsTemplate
import de.learnlib.studio.experiment.codegen.templates.config.CommandLineOptionsHandlerTemplate
import de.learnlib.studio.experiment.codegen.templates.serialization.ExperimentDataDeserializerTemplate
import de.learnlib.studio.experiment.codegen.providers.ExperimentConfigurationsProvider

class MainTemplate extends AbstractSourceTemplate {

    new(GeneratorContext context) {
        super(context, "Main")
    }

    override template() '''
        package «package»;
        
        import java.util.List;
        import java.util.ArrayList;
        import java.util.Date;
        import java.text.DateFormat;
        import java.text.SimpleDateFormat;
        
        
        	« val ePath = context.modelPackage + ".util.EvaluationWriter"  »
        	        import «  ePath »;
        
        import « reference(CommandLineOptionsTemplate) »;
        import « reference(CommandLineOptionsHandlerTemplate) »;
        import « reference(ExperimentDataTemplate) »;
        import « reference(ExperimentDataDeserializerTemplate) »;
        
        
        public class Main {
        	
            public static void main(String[] args) {
                rememberStartDateTime();
                
                CommandLineOptionsHandler optionsHandler = new CommandLineOptionsHandler();
                boolean parsingOk = optionsHandler.parse(args);
                
                if (parsingOk) {
                     	if (CommandLineOptions.SELECT_CONFIGURATION.isSet()) {
                     	List<AbstractExperiment> experiments = createExperiments();
                    	String configurationNoAsString = System.getProperty(CommandLineOptions.SELECT_CONFIGURATION.getSystemProperty());
                    	System.out.println("Selected Configuration No. " + configurationNoAsString);
                    	
                    	int configurationNo = Integer.parseInt(configurationNoAsString) - 1;
                    	AbstractExperiment experiment = experiments.get(configurationNo);
                    	
                    	experiment.executeAll();
                    	} else {
                        	runAllExperiments();
                    	}
                }
            }
            
            private static void rememberStartDateTime() {
                Date currentDateTime = new Date();
                DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd-HH-mm-ss");
                String currentDateTimeAsString = dateFormat.format(currentDateTime);
                
                System.setProperty("EXPERIMENT_START_TIME", currentDateTimeAsString);
            }
            
            private static List<AbstractExperiment> createExperiments() {
            	List<AbstractExperiment> experiments = new ArrayList<>(« experimentClassNames.size »);
            	« FOR experimentName : experimentClassNames SEPARATOR "\n" »
            	«experimentName» «experimentName.toFirstLower» = new «experimentName»();
                    experiments.add(« experimentName.toFirstLower »);
                « ENDFOR »
            	
            	return experiments;
        	}
        	
        	private static void printConfigurationsList(List<AbstractExperiment> experiments) {
        		for (int i = 0; i < experiments.size(); i++) {
                    
                }
        	}
        	
        	private static void runAllExperiments() {
        		« val first = experimentClassNames.get(0) »
        		« first » « first.toFirstLower » = new « first »();
        		EvaluationWriter.writeHeader(« first.toFirstLower ».getCounterInformationAsString());
        		«FOR experimentName : experimentClassNames»
        		for(int i = 0;i < «context.model.numberofIterations»;i++)run«experimentName»();
        		« ENDFOR »
        	}
        	« FOR experimentName : experimentClassNames »
        	private static void run«experimentName»(){
        		«experimentName» «experimentName.toFirstLower» = new «experimentName»();
        		 if (CommandLineOptions.RESUME.isSet()) {
        		 	String fileName = System.getProperty(CommandLineOptions.RESUME.getSystemProperty());
        		 	ExperimentDataDeserializer deserializer = new ExperimentDataDeserializer();
        		 	ExperimentData data = deserializer.read(fileName);
        			 «experimentName.toFirstLower».setData(data);
        		 }
        		                    
        		 if (CommandLineOptions.SINGLE_STEP.isSet()) {
        		 	«experimentName.toFirstLower».executeOne();
        		 } else {
        		 	«experimentName.toFirstLower».executeAll();
        		 }
        	}	
        	« ENDFOR »
          
        }
        
    '''

    def getExperimentClassNames() {
        val configurations = context.getProvider(ExperimentConfigurationsProvider).configurations
        val baseName = context.model.name.toFirstUpper
        
        if (configurations.size == 1) {
            return #[baseName]
        } else {
            val results = newLinkedList()
            configurations.forEach[config, i |
                results += baseName + (i + 1)  
            ]
            return results
        }
    }

}
