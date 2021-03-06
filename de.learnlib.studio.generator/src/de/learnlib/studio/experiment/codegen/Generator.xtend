package de.learnlib.studio.experiment.codegen

import java.lang.reflect.Modifier

import graphmodel.Node
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.Platform
import org.reflections.Reflections
import org.reflections.scanners.SubTypesScanner
import org.reflections.util.ConfigurationBuilder
import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator

import de.learnlib.studio.experiment.codegen.templates.PerNodeTemplate
import de.learnlib.studio.experiment.experiment.Experiment
import de.learnlib.studio.experiment.codegen.templates.Template
import de.learnlib.studio.experiment.codegen.templates.NodeRelatedTemplate
import de.learnlib.studio.experiment.codegen.utils.ObjectFactory
import de.learnlib.studio.experiment.codegen.providers.NodeRelatedGeneratorInformationProvider
import de.learnlib.studio.experiment.codegen.providers.GeneratorInformationProvider

import static de.learnlib.studio.experiment.codegen.utils.ReflectionUtils.getAllInterfaces
import static de.learnlib.studio.experiment.codegen.utils.ReflectionUtils.getGenericTypeParameter


class Generator implements IGenerator<Experiment> {
	
	val Reflections   reflections
	val ObjectFactory objectFactory
	
	
	new() {
	    val bundle = Platform.getBundle("de.learnlib.studio.generator")
        val bundlEntryURL = FileLocator.resolve(bundle.getEntry("/"))
        
        this.reflections = new Reflections(new ConfigurationBuilder()
                                                .setScanners(new SubTypesScanner())
                                                .setUrls(bundlEntryURL)
                                                .addClassLoader(GeneratorContext.classLoader)
        )
        this.objectFactory = new ObjectFactory()
	}
	
	override generate(Experiment model, IPath targetDir, IProgressMonitor progressMonitor) {
		val context = new GeneratorContext(model)
		
		findCreateAndRegisterProviders(context)
		
		val templateObjects = findAndCreateTemplateObjects(model, context)
		templateObjects.forEach[o | o.generate(model, targetDir, progressMonitor)]
		
		//objectFactory.printStatistics()
		objectFactory.clear()
	}
	
	   def findCreateAndRegisterProviders(GeneratorContext context) {
        val providers = reflections.getSubTypesOf(GeneratorInformationProvider)
        
        providers.filter[t | !Modifier.isAbstract(t.modifiers)].forEach[t |
            val interfaces = getAllInterfaces(t)
            interfaces.forEach[interfaceClass |
                if (NodeRelatedGeneratorInformationProvider.isAssignableFrom(t)) {
                    val nodeType = getGenericTypeParameter(t, NodeRelatedGeneratorInformationProvider)
                    if (nodeType !== null) {
                        context.getNodes(nodeType).forEach[node, i |
                            val newProvider = objectFactory.getInstance(t, nodeType, context, node, i) as NodeRelatedGeneratorInformationProvider<? extends Node>
                            context.addProvider(node, interfaceClass as Class<? extends NodeRelatedGeneratorInformationProvider<? extends Node>>, newProvider)
                        ]
                    }
                } else {
                    val newProvider = objectFactory.getInstance(t, context) as GeneratorInformationProvider
                    context.addProvider(interfaceClass as Class<? extends GeneratorInformationProvider>, newProvider)
                }
            ]
        ]
    }
	
	
	def findAndCreateTemplateObjects(Experiment model, GeneratorContext context) {
	    val templates = reflections.getSubTypesOf(Template)
		val templateObjects = <Template> newHashSet()
		templates.filter[t | !Modifier.isAbstract(t.modifiers)].forEach[t |
			if (PerNodeTemplate.isAssignableFrom(t)) {
				val nodeType = getGenericTypeParameter(t, PerNodeTemplate)
				context.getNodes(nodeType).forEach[node, i|
					templateObjects += objectFactory.getInstance(t, nodeType, context, node, i) as Template
				]
			} else if (NodeRelatedTemplate.isAssignableFrom(t)) {
				val nodeType = getGenericTypeParameter(t, NodeRelatedTemplate)
				if (context.isNodeTypeUsed(nodeType)) {
					templateObjects += objectFactory.getInstance(t, context) as Template
				}
			} else {
				templateObjects += objectFactory.getInstance(t, context) as Template
			}
		]
		
		return templateObjects
	}
	
}
