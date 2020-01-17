package de.learnlib.studio.experiment.codegen.templates.blocks.learner

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.experiment.ADTAlgorithm
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.experiment.QueryEdge
import de.learnlib.studio.experiment.experiment.ADTExtender

class ADTBlockTemplate extends AbstractLearnerBlockTemplate<ADTAlgorithm> implements PerNodeTemplate<ADTAlgorithm> {
	
	@Data
	static class LeafSplitterConstructorWrapper {
		val String leafSplitter
		
		override toString() {
			return leafSplitter
		}
	}
	
	@Data
	static class ADTExtenderConstructorWrapper {
		val String adtExtender
		
		override toString() {
			return adtExtender
		}
	}
	
	@Data
	static class SubtreeReplacerConstructorWrapper {
		val String subtreeReplacer
		
		override toString() {
			return subtreeReplacer
		}
	}
	
	new(GeneratorContext context) {
        this(context, null, -1)
    }
	
	new(GeneratorContext context, ADTAlgorithm learner, int i) {
		super(context, learner, i , "adtLearner", "learnlib-adt", "de.learnlib.algorithms.adt.learner", "ADTLearner", "ADTLearnerBuilder", " de.learnlib.algorithms.adt.learner", "ADTLearnerState")
	}
	
	override getAdditionalLearnerImports() {
        return #["de.learnlib.algorithms.adt.api.ADTExtender","de.learnlib.algorithms.adt.api.LeafSplitter","de.learnlib.algorithms.adt.api.SubtreeReplacer"]
    }
    
	override getExperimentImports() {
		return super.experimentImports + #["de.learnlib.algorithms.adt.config.ADTExtenders","de.learnlib.algorithms.adt.config.LeafSplitters","de.learnlib.algorithms.adt.config.SubtreeReplacers"]
	}
	
    override getAdditionalVariables() {
        return #["LeafSplitter" -> "leafSplitter", "ADTExtender" -> "adtExtender", "SubtreeReplacer" -> "subtreeReplacer", "Boolean" -> "useObservationTrees"]
    }
	
    override getConstructorParameters() {
       var oracleNode = getOutgoing(QueryEdge).get(0).targetElement
        
        return #[name, oracleNode, leafSplitterAsConstructorParameter, ADTExtenderAsConstructorParameter, subtreeReplacerAsConstructorParameter, node.useObservationTrees]
    }
    
    
    
    private def getLeafSplitterAsConstructorParameter(){
    	val leafSplitterEnumName = switch (node.leafSplitter){
    		case DEFAULT_SPLITTER:	"DEFAULT_SPLITTER"
    		case EXTEND_PARENT : 	"EXTEND_PARENT"
    	}
    	
    	val fullLeafSplitterName = "LeafSplitters." + leafSplitterEnumName
    	
    	return new LeafSplitterConstructorWrapper(fullLeafSplitterName)
    	
    }
    
    override protected getBuilderStatement() '''
        learner = new « builderClass »<String, String>()
                                               .withAlphabet(oracle.getAlphabet())
                                               .withOracle(oracle.getOracle())
                                               .withLeafSplitter(leafSplitter)
                                               .withSubtreeReplacer(subtreeReplacer)
                                               .withAdtExtender(adtExtender)
                                               .withUseObservationTree(useObservationTrees)
                                               .create();
    '''
    
    private def getADTExtenderAsConstructorParameter(){
    	val adtExtenderEnumName = switch(node.adtExtender){
    		case EXTEND_BEST_EFFORT : 	"EXTEND_BEST_EFFORT"
    		case NOP				:	"NOP"				
    	}
    	
    	val fullExtenderName = "ADTExtenders." + adtExtenderEnumName
    	
    	return new ADTExtenderConstructorWrapper(fullExtenderName)
    }
    
    private def getSubtreeReplacerAsConstructorParameter(){
    	val replacerEnumName = switch(node.subtreeReplacer){
    		case NEVER_REPLACE:			"NEVER_REPLACE"	
    		case LEVELED_BEST_EFFORT:		"LEVELED_BEST_EFFORT"
    		case LEVELED_MIN_LENGTH:		"LEVELED_MIN_LENGTH"
    		case LEVELED_MIN_SIZE:			"LEVELED_MIN_SIZE"
    		case EXHAUSTIVE_BEST_EFFORT:	"EXHAUSTIVE_BEST_EFFORT"	
    		case EXHAUSTIVE_MIN_LENGTH:		"EXHAUSTIVE_MIN_LENGTH"
    		case EXHAUSTIVE_MIN_SIZE:		"EXHAUSTIVE_MIN_SIZE"
    		case SINGLE_BEST_EFFORT:		"SINGLE_BEST_EFFORT"
    		case SINGLE_MIN_LENGTH:			"SINGLE_MIN_LENGTH"
    		case SINGLE_MIN_SIZE:			"SINGLE_MIN_SIZE"
    	}
    	val fullReplacerName = "SubtreeReplacers." + replacerEnumName
    	
    	return new SubtreeReplacerConstructorWrapper(fullReplacerName)
    }
}
