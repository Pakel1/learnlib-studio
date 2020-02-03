package de.learnlib.studio.experiment.codegen.providers

import graphmodel.Node


interface MealyInformationProvider<N extends Node> extends RuntimeInformationProvider<N> {
	
	def Integer numberOfStates();
	
	def Integer inputLength();
	
	def Integer outputLength();
}
