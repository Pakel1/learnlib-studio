package de.learnlib.studio.experiment.checks

import de.learnlib.studio.experiment.mcam.modules.checks.ExperimentCheck
import de.learnlib.studio.experiment.experiment.Experiment

import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.getAllLearners
import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.getAllEQOralces
import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.getAllOracles
import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.getAllFilters
import static extension de.learnlib.studio.experiment.utils.ExperimentExtensions.isChildOfAComplexNode
import de.learnlib.studio.experiment.experiment.SULSymbolQueryOracle
import de.learnlib.studio.experiment.experiment.ADTAlgorithm
import de.learnlib.studio.experiment.experiment.SuperOracle
import de.learnlib.studio.experiment.experiment.ParallelOracle

class ADTChecks extends ExperimentCheck{
	
	override check(Experiment model) {
		checkMsOracle(model)
		checkSuperOracle(model)
	}
	
	private def checkSuperOracle(Experiment model) {
		val adtLearner = model.allLearners.filter[n| n instanceof ADTAlgorithm]
		val superOracle = model.allOracles.filter[n| n instanceof SuperOracle]
		val parallelOracle = model.allOracles.filter[n| n instanceof ParallelOracle]
		val sqOracles = model.allOracles.filter[n| n instanceof SULSymbolQueryOracle]
		if(adtLearner.size > 0 && parallelOracle.size > 0 && superOracle.size == 0){
			addError(adtLearner.get(0),"You need a Super Oracle for handling parallelism and ADT Algorithm together")
		}
		if(parallelOracle.size == 0 && superOracle.size > 0){
			addError(superOracle.get(0), "You only need a Super Oracle for handling parallelism and ADT Algorithm together")
		}
		if(superOracle.size > 0 && sqOracles.size == 0){
			addError(superOracle.get(0),"A Super Oracle needs at least one Symbol Query Oracle in the Parallel Oracle pipeline")
		}
	}
	
	private def checkMsOracle(Experiment model) {
		val adtLearner = model.allLearners.filter[n| n instanceof ADTAlgorithm]
		if(adtLearner.size > 0){
			val sqOracles = model.allOracles.filter[n| n instanceof SULSymbolQueryOracle]
			if(sqOracles.size == 0) addError(adtLearner.get(0), "You need at least one Symbol Query Oracle for the ADT Algorithm")
		}
	}
	
}