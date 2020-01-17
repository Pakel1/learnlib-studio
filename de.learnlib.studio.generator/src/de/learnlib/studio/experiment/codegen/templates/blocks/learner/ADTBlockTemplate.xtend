package de.learnlib.studio.experiment.codegen.templates.blocks.learner

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.experiment.ADTAlgorithm
import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.experiment.QueryEdge

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
		return super.experimentImports + #["de.learnlib.algorithms.adt.api.ADTExtender","de.learnlib.algorithms.adt.api.LeafSplitter","de.learnlib.algorithms.adt.api.SubtreeReplacer"]
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
    		case "DefaultSplitter":	"DEFAULT_SPLITTER"
    		case "ExtendParent" : 	"EXTEND_PARENT"
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
    		case "ExtendBestEffort" : 	"EXTEND_BEST_EFFORT"
    		case "Nop":					"NOP"				
    	}
    	
    	val fullExtenderName = "ADTExtenders." + adtExtenderEnumName
    	
    	return new ADTExtenderConstructorWrapper(fullExtenderName)
    }
    
    private def getSubtreeReplacerAsConstructorParameter(){
    	val replacerEnumName = switch(node.subtreeReplacer){
    		case "NeverReplace":			"NEVER_REPLACE"	
    		case "LeveledBestEffort":		"LEVELED_BEST_EFFORT"
    		case "LeveledMinLength":		"LEVELED_MIN_LENGTH"
    		case "LeveledMinSize":			"LEVELED_MIN_SIZE"
    		case "ExhaustiveBestEffort":	"EXHAUSTIVE_BEST_EFFORT"	
    		case "ExhaustiveMinLength":		"EXHAUSTIVE_MIN_LENGTH"
    		case "ExhaustiveMinSize":		"EXHAUSTIVE_MIN_SIZE"
    		case "SingleBestEffort":		"SINGLE_BEST_EFFORT"
    		case "SingleMinLength":			"SINGLE_MIN_LENGTH"
    		case "SingleMinSize":			"SINGLE_MIN_SIZE"
    	}
    	val fullReplacerName = "SubtreeReplacers." + replacerEnumName
    	
    	return new SubtreeReplacerConstructorWrapper(fullReplacerName)
    }
}
