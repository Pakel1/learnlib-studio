package de.learnlib.studio.experiment.codegen.templates

import java.util.List

import graphmodel.Node
import graphmodel.Container
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor

import de.learnlib.studio.experiment.experiment.Experiment
import de.learnlib.studio.experiment.experiment.Filter
import de.learnlib.studio.experiment.experiment.Oracle
import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.templates.oracles.ExperimentOracleInterfaceTemplate
import de.learnlib.studio.experiment.codegen.templates.blocks.BlockInterfaceTemplate
import de.learnlib.studio.experiment.codegen.providers.ExperimentRuntimeInformationProvider
import de.learnlib.studio.experiment.codegen.providers.OracleInformationProvider
import de.learnlib.studio.experiment.codegen.utils.ExperimentConfigurationsHelper.ExperimentConfiguration
import de.learnlib.studio.experiment.codegen.providers.RuntimeInformationProvider
import de.learnlib.studio.experiment.codegen.providers.ExperimentConfigurationsProvider

import de.learnlib.studio.experiment.experiment.SULMembershipOracle
import de.learnlib.studio.experiment.experiment.QueryCounterFilter

import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isComplexNode
import de.learnlib.studio.experiment.codegen.providers.MealyInformationProvider
import de.learnlib.studio.experiment.experiment.MealySul
import de.learnlib.studio.experiment.codegen.templates.oracles.ExperimentMealyInterfaceTemplate
import de.learnlib.studio.experiment.codegen.templates.oracles.ExperimentSymbolOracleInterfaceTemplate
import de.learnlib.studio.experiment.experiment.SULSymbolQueryOracle
import de.learnlib.studio.experiment.experiment.SymbolCounterFilter
import de.learnlib.studio.experiment.experiment.SymbolCacheFilter
import de.learnlib.studio.experiment.experiment.ParallelOracle
import de.learnlib.studio.experiment.experiment.SuperOracle
import de.learnlib.studio.experiment.experiment.CacheFilter
import de.learnlib.studio.experiment.experiment.QSRCounterFilter
import de.learnlib.studio.experiment.experiment.SUL
import de.learnlib.studio.experiment.experiment.Learner
import de.learnlib.studio.experiment.experiment.EQOracle
import de.learnlib.studio.experiment.experiment.LStarAlgorithm
import de.learnlib.studio.experiment.experiment.KVAlgorithm
import de.learnlib.studio.experiment.experiment.DTAlgorithm
import de.learnlib.studio.experiment.experiment.TTTAlgorithm
import de.learnlib.studio.experiment.experiment.ADTAlgorithm
import de.learnlib.studio.experiment.experiment.DHCAlgorithm
import de.learnlib.studio.experiment.experiment.RandomMealySUL

class ExperimentTemplate extends AbstractSourceTemplate {

    var ExperimentConfiguration currentConfiguration
    var int i

    new(GeneratorContext context) {
        super(context, context.model.name)
        this.context = context
    }
    
    private def getOracleInformationProviders() {
        val oracles = currentConfiguration.nodes.filter[n | n instanceof Oracle && !(n instanceof Filter) &&
        	!(n instanceof ParallelOracle) && !(n instanceof SuperOracle)]
        
        val result = <OracleInformationProvider<? extends Node>> newLinkedList()
        val queue = <Node> newLinkedList(oracles)
        val done  = <Node> newHashSet()
        while(!queue.empty) {
            val currentNode = queue.poll
            
            queue  += currentNode.predecessors.filter[n | !done.contains(n) && n instanceof Filter]
            done   += currentNode
            
            if (currentNode.isComplexNode) {	            
	            val realCurrentNode = currentConfiguration.getNode(currentNode as Container)
	            
	            val nodeChain = newLinkedList(realCurrentNode)
	            while (!nodeChain.last.successors.nullOrEmpty) {
	            	nodeChain += nodeChain.last.successors
	            }
	            
	            nodeChain.reverse.forEach[n |
	            	addNodeToResult(result, n)
            	]
            } else {
            	addNodeToResult(result, currentNode)
            }
        }
        
        val parallelOracle = currentConfiguration.nodes.filter[n | n instanceof ParallelOracle]
        if(!parallelOracle.isEmpty) addNodeToResult(result, parallelOracle.get(0))
        
        val superOracle = currentConfiguration.nodes.filter[n | n instanceof SuperOracle]
        if(!parallelOracle.isEmpty) addNodeToResult(result, superOracle.get(0))
        
       	val cache = currentConfiguration.nodes.filter[n | n instanceof CacheFilter && !done.contains(n)]
       	if(!cache.isEmpty) addNodeToResult(result, cache.get(0))
       	
       	return result
    }
    
    private def getMealyInformationProviders(){
    	val mealys = currentConfiguration.nodes.filter[x | x instanceof SUL]
    	System.out.println(mealys.head.isComplexNode)
    	val result = <MealyInformationProvider<? extends Node>> newLinkedList()
    	for (currentNode : mealys) {
    		 if (currentNode.isComplexNode) {	            
	            val realCurrentNode = currentConfiguration.getNode(currentNode as Container)
	            
	            val nodeChain = newLinkedList(realCurrentNode)
	            while (!nodeChain.last.successors.nullOrEmpty) {
	            	nodeChain += nodeChain.last.successors
	            }
	            
	            nodeChain.reverse.forEach[n |result += context.getProvider(n, MealyInformationProvider)]
            } else {
            	result += context.getProvider(currentNode, MealyInformationProvider)
            }
    		
    	}
    	System.out.println(result.length)
    	return result
    }
    
    private def addNodeToResult(List<OracleInformationProvider<? extends Node>> result, Node node) {
    	val provider = context.getProvider(node, OracleInformationProvider)
        if (provider === null) {
            println("No OracleInformationProvider for " + node)
        } else {
            result += context.getProvider(node, OracleInformationProvider)
        }
    }
    
    override generate(Experiment model, IPath targetDir, IProgressMonitor progressMonitor) {
        val configurations = context.getProvider(ExperimentConfigurationsProvider).configurations
        if (configurations.size > 1) {
            configurations.forEach[config, counter |
                currentConfiguration = config
                i = counter + 1
                fileName = className + ".java"
                super.generate(model, targetDir, progressMonitor)
            ]
        } else {
            currentConfiguration = configurations.head
            i = -1
            super.generate(model, targetDir, progressMonitor)
        }
    }
    
    override getClassName() {
        if (i == -1) {
            return super.className
        } else {
            return super.className + i
        }
    }

    override template() '''
        « val oiProviders = getOracleInformationProviders() »
        « val eiProviders = getCurrentExperimentRuntimeInformationProvider() »
        « val miProviders = getMealyInformationProviders() »
        package « package »;
        
        « importsTemplate(oiProviders, miProviders) »
        
        « val ePath = context.modelPackage + ".util.EvaluationWriter"  »
                	        import «  ePath »;
        
        
        public class « className » extends AbstractExperiment {
        	
        	« mealyDefinitionTemplate(miProviders) »
            
            « oracleDefinitionTemplate(oiProviders) »
            
            « blockDefinitionTemplate() »
            
             private long startTime;
            
            
            
            
            public « className »() {
                super();
                
                « mealyInitializationTemplate(miProviders) »
                
                « oracleInitializationTemplate(oiProviders) »
                
                « blockInitializationTemplate() »
                
                « callTableTeamplate() »
                
                // Preparing for the run
                this.current = start;
            }
            
            @Override
            public String getAlgorithmInformationAsString(){
            	return "«writeAlgorithmInformation(eiProviders.filter[e | e.node instanceof Learner].head)»";
            }
            
            @Override
            public String getEqOracleInformationAsString() {
            	return "« FOR ei : eiProviders.filter[e | e.node instanceof EQOracle] SEPARATOR ", "»« ei.className »« ENDFOR»";
            }
            
            @Override
            public String getCounterInformationAsString() {
            	return "«FOR oi: oracleInformationProviders.filter[o | o.node instanceof QSRCounterFilter ] SEPARATOR ";"»SC_«oi.className»;QRC_«oi.className»«ENDFOR »;" + 
            	"SC_Total;QRC_Total"; }
                        
            @Override
            public String getSulInformationAsString() {
            	return "«writeSulInformation(miProviders.head)»";
            }
            
            
            
            @Override
            public void setUp() {
            	startTime = System.currentTimeMillis();
                « IF i != -1 »
                    System.setProperty("« context.modelName ».currentConfiguration", "« i »");
                « ENDIF »
                
                « FOR o : oiProviders.filter[o | o.node instanceof SULMembershipOracle] »
                    ((«o.className») « o.name  »).setUp();
                « ENDFOR »
            }
            
            @Override
            public void dispose() {
                « FOR o : oiProviders.filter[o | o.node instanceof QueryCounterFilter || o.node instanceof QSRCounterFilter] »
                    ((«o.className») « o.name  »).dispose();
                « ENDFOR »
                « FOR o : oiProviders.filter[o | o.node instanceof SULMembershipOracle] »
                    ((«o.className») « o.name  »).dispose();
                « ENDFOR »
                 writeEvaluationData();
                      }
                      
            public void writeEvaluationData(){
            
                             long time = System.currentTimeMillis() - startTime;
                             EvaluationWriter.writeConfigurationData(getAlgorithmInformationAsString(),getEqOracleInformationAsString(),getSulInformationAsString(),
                             « val oracles = oiProviders.filter[n| n.node instanceof ParallelOracle]»
                               				«IF(oracles.size != 0) »
                               					((ParallelOracle)parallelOracle).getCounts()
                               				«ENDIF»
                               				«IF(oracles.size == 0)»
                               « val counter = oiProviders.filter[n| n.node instanceof QSRCounterFilter].get(0)»
                                      ((«counter.className») « counter.name  »).getCounts()
                                     «ENDIF»
                                     , time );
                         }
        }
        
    '''
	
	
	def writeSulInformation(MealyInformationProvider<? extends Node> provider) {
		return provider.className + "(" + provider.numberOfStates + "," + provider.inputLength + "," + provider.outputLength + ")"
	}
	
	
	
	
	
	def writeAlgorithmInformation(ExperimentRuntimeInformationProvider learner) {
		val firstLetter = learner.node.nodeName.toString.substring(0,1)
		val out = switch(firstLetter){
			case "l": 	"L*"
			case "k":	"KV"
			case "d":	findCorrect(learner)
			case "t":	writeTTTInformation(learner.node)
			case "a":	writeADTInformation(learner.node)
		}
		return out
	}
	
	def findCorrect(ExperimentRuntimeInformationProvider provider) {
		val secondLetter = provider.node.nodeName.toString.substring(1,2)
		if(secondLetter.equals("t")) return "DT"
		return "DHC"
	}
	
	def writeADTInformation(Node node) {
		val adtNode = node as ADTAlgorithm
		
		val leafSplitterName = switch (adtNode.leafSplitter){
    		case DEFAULT_SPLITTER:	"DS"
    		case EXTEND_PARENT : 	"EP"
    	}
    	
    	val adtExtenderName = switch(adtNode.adtExtender){
    		case EXTEND_BEST_EFFORT : 	"EBE"
    		case NOP				:	"N"				
    	}
    	
    	
    	val replacerName = switch(adtNode.subtreeReplacer){
    		case NEVER_REPLACE:				"NR"	
    		case LEVELED_BEST_EFFORT:		"LBE"
    		case LEVELED_MIN_LENGTH:		"LML"
    		case LEVELED_MIN_SIZE:			"LMS"
    		case EXHAUSTIVE_BEST_EFFORT:	"EBE"	
    		case EXHAUSTIVE_MIN_LENGTH:		"EML"
    		case EXHAUSTIVE_MIN_SIZE:		"EMS"
    		case SINGLE_BEST_EFFORT:		"SBE"
    		case SINGLE_MIN_LENGTH:			"SML"
    		case SINGLE_MIN_SIZE:			"SMS"
    	}
    	
    	val useObservationTrees = switch(adtNode.useObservationTrees){
    		case TRUE:	"T"
    		case FALSE:	"F"
    	}
    	
    	return "ADT(" + leafSplitterName + "," + adtExtenderName + "," + replacerName + "," + useObservationTrees + ")"
	}
	
	def writeTTTInformation(Node node) {
		val tttNode = node as TTTAlgorithm
		val analyzerName = switch (tttNode.acexAnalyzer) {
	        case LINEAR_FORWARD:         "L_FWD"
	        case LINEAR_BACKWARD:        "L_BWD"
	        case BINARY_SEARCH_BACKWARD: "B_S_BWD"
	        case BINARY_SEARCH_FORWARD:  "B_S_FWD"
	        case EXPONENTIAL_BACKWARD:   "E_BWD"
	        case EXPONENTIAL_FORWARD:    "E_FWD"
	    }
	    
	    return "TTT(" + analyzerName + ")"
	}

    def importsTemplate(List<OracleInformationProvider<? extends Node>> oiProviders, List<MealyInformationProvider<? extends Node >> miProviders) '''
        import « reference(ExperimentOracleInterfaceTemplate) »;
        import « reference(ExperimentSymbolOracleInterfaceTemplate) »;
        « FOR p : oiProviders »
            « FOR i : p.experimentImports »
                import « i »;
            « ENDFOR »
          	« IF p.node instanceof ParallelOracle »
          	 	import de.learnlib.oracle.parallelism.StaticParallelOracle;
          	« ENDIF»
        « ENDFOR »
        
        import « reference(ExperimentMealyInterfaceTemplate) »;
                « FOR p : miProviders »
                    « FOR i : p.experimentImports »
                        import « i »;
                    « ENDFOR »
                « ENDFOR »
        
        import « reference(BlockInterfaceTemplate) »;
        « FOR p : getCurrentExperimentRuntimeInformationProvider() »
            « FOR i : p.experimentImports »
            	import « i »;
            « ENDFOR »
        « ENDFOR »
    '''

    def oracleDefinitionTemplate(List<OracleInformationProvider<? extends Node>> oiProviders) '''
        // Define the Oracles & Filters
        « FOR p : oiProviders »
        « IF p.node instanceof SULSymbolQueryOracle ||
        	 p.node instanceof SymbolCacheFilter ||
        	 p.node instanceof SymbolCounterFilter ||
        	 p.node instanceof SuperOracle ||
        	 p.node instanceof QSRCounterFilter »
            private ExperimentSymbolOracle « p.name »;
        « ELSE»
        	private ExperimentOracle « p.name »;
        « ENDIF»
        « ENDFOR »
    '''
    
    def mealyDefinitionTemplate(List<MealyInformationProvider<? extends Node>> miProviders)   '''
    	//Define the Mealys
    	« FOR m : miProviders »
    		private ExperimentMealy « m.name »;
    	« ENDFOR »
    '''

    def blockDefinitionTemplate() '''
        // Define the Blocks
        « FOR p : getCurrentExperimentRuntimeInformationProvider() »
            private Block « p.name »;
        « ENDFOR »
    '''
    
    def oracleInitializationTemplate(List<OracleInformationProvider<? extends Node>> oiProviders) '''
        // Init. the Oracles & Filters
        « FOR p : oiProviders »
            this.« p.name » = new « p.className »(« getConstructorParameterList(p) »);
        « ENDFOR »
    '''
    
    def mealyInitializationTemplate(List<MealyInformationProvider<? extends Node>> miProviders) '''
        // Init. the Mealys
        « FOR p : miProviders »
            this.« p.name » = new « p.className »();
        « ENDFOR »
    '''
    
    private def String getConstructorParameterList(RuntimeInformationProvider<? extends Node> provider) '''
        « FOR p : provider.getConstructorParameters() SEPARATOR ", " »« formatParameter(p) »« ENDFOR »'''
    
    private def formatParameter(Object parameter) {
        switch (parameter) {
            Node:    getNodeName(parameter)
            String:  '"' + parameter + '"'
            default: parameter.toString()
        }
    }
    
    def blockInitializationTemplate() '''
        // Init. the Blocks
        « FOR p : getCurrentExperimentRuntimeInformationProvider() »
            this.« p.name » = new « p.className »(« getConstructorParameterList(p) »);
        « ENDFOR »
    '''
    
    def callTableTeamplate() '''
        // Define the 'calltable'
        « FOR p : getCurrentExperimentRuntimeInformationProvider() »
            « FOR s : p.successors as List<Pair<String, Node>> »
                « val successorName = getNodeName(s.value) »
                ((« p.className ») « p.name »).set« s.key.toFirstUpper »Successor(« successorName »);
            « ENDFOR »
        « ENDFOR »
    '''

    def getCurrentExperimentRuntimeInformationProvider() {
        val currentRuntimeInforamtionProviders = newHashSet()
        
        currentConfiguration.nodes.forEach[node | 
            val provider = context.getProviders(node, ExperimentRuntimeInformationProvider)
            if (provider !== null) {
                currentRuntimeInforamtionProviders += provider
            }
        ]
        
        return currentRuntimeInforamtionProviders
    }
    
    def getNodeName(Node node) {
        val realNode = if (node.isComplexNode) { currentConfiguration.getNode(node as Container) }
                       else                    { node }
                            
        val nodeInformationProvider = context.getProvider(realNode, RuntimeInformationProvider)                
        
        if (nodeInformationProvider === null) {
            println("No Runtime Information for " + realNode + " (" + node + ")")
            return ""
        } else {
            return nodeInformationProvider.name
        }
    }

}
