package de.learnlib.studio.experiment.codegen.templates

import de.learnlib.studio.experiment.codegen.GeneratorContext
import de.learnlib.studio.experiment.codegen.templates.serialization.ExperimentDataSerializerTemplate
import de.learnlib.studio.experiment.codegen.templates.blocks.BlockInterfaceTemplate
import de.learnlib.studio.experiment.codegen.templates.utils.ResultWriterTemplate

class AbstractExperimentTemplate extends AbstractSourceTemplate {

    new(GeneratorContext context) {
        super(context, "AbstractExperiment")
    }
                
    override template() '''
        package « package »;
        
        import java.lang.reflect.Field;
        import java.util.Map;
        import java.util.HashMap;
        import java.util.logging.Logger;
        
        import « reference(BlockInterfaceTemplate) »;
        import « reference(ExperimentDataSerializerTemplate) »;
        import « reference(ResultWriterTemplate)»;
        
        
        public abstract class AbstractExperiment {
            
            private final static Logger LOGGER = Logger.getLogger(« className ».class.getName());
            
            protected ExperimentData data;
            protected ExperimentDataSerializer serializer;
            
            protected Block current;
            protected Map<Block, Map<String, Block>> callTable;
            
            public AbstractExperiment() {
                this.data       = new ExperimentData();
                this.serializer = new ExperimentDataSerializer();
            }
            
            public void setData(ExperimentData data) {
                this.data    = data;
                
                try {
                    String currentBlockid = data.getCurrentBlockId();
                    Field blockInExperiment = getClass().getDeclaredField(currentBlockid);
                    blockInExperiment.setAccessible(true);
                    this.current = (Block) blockInExperiment.get(this);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
            public abstract String getAlgorithmInformationAsString();
            
            public abstract String getSulInformationAsString();
            
            public abstract String getEqOracleInformationAsString();
            
            public abstract String getCounterInformationAsString();
            
            public void executeAll() {
                long startTime = System.currentTimeMillis();
                
                setUp();
                while (current != null) {
                    executeOneInternal();
                }
                dispose();
                
                long time = System.currentTimeMillis() - startTime;
            }
            
            public void executeOne() {
                setUp();
                executeOneInternal();
                dispose();
            }
            
            private void executeOneInternal() {
                
                Block result = current.execute(data);
                
                String endMessage = current.endMessage();
                
                if (result != null) {
                    current = result;
                    data.setCurrentBlock(current);
                } else {
                    current = null;
                    System.out.println();
                    System.out.println("Experiment finished.");
                }
            }
            
            public abstract void setUp();
            
            public abstract void dispose();
            
        }
    '''    
    
}
